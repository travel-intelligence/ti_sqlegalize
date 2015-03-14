module TiSqlegalize
  class Query
    @queue = :query

    DEFAULT_QUOTA = 100_000

    CURSOR_BATCH = 1024

    attr_accessor :id, :statement, :status, :quota, :count

    def create!
      unless id
        token = SecureRandom.hex(16)
        seq = Resque.redis.incr('ti_sqlegalize:query:seq')
        @id = [token, seq].join('_')
        @status = :created
        save!
      end
    end

    def save!
      k = self.class.meta_key id
      Resque.redis.set(k, meta.to_json) if k
    end

    def meta
      {
        status: status,
        statement: statement,
        count: count,
        quota: quota
      }
    end

    def [](offset, limit)
      k = self.class.main_key id
      if k
        Resque.redis.lrange(k, offset, offset + limit - 1)
      else
        []
      end
    end

    def <<(rows)
      k = self.class.main_key id
      if k
        self.count = Resque.redis.rpush(k, rows)
      end
    end

    def initialize(statement, quota = DEFAULT_QUOTA)
      @statement = statement.to_s
      @quota = quota.to_i
      @count = 0
    end

    def enqueue!
      Resque.enqueue(self.class, id) if id
    end

    def run
      cursor = self.class.execute statement
      cursor.each_slice(CURSOR_BATCH) do |chunk|
        rows = if count + chunk.length <= quota
                 chunk
               else
                 chunk.take(quota - count)
               end
        self << rows
        break if count >= quota
      end
      cursor.close if cursor.respond_to? :close
      self.status = :finished
      save!
    end

    def self.find(id)
      k = meta_key id
      m = Resque.redis.get(k) if k
      if m
        meta = MultiJson.load m
        query = new(meta['statement'], meta['quota'])
        query.id = id
        query.status = meta['status'].to_sym
        query.count = meta['count']
        query
      end
    end

    def self.main_key(id)
      "ti_sqlegalize:query:#{id}" if id
    end

    def self.meta_key(id)
      "ti_sqlegalize:query:#{id}:meta" if id
    end

    def self.perform(id)
      query = find id
      if query
        Rails.logger.info "Job #{id}: #{query.statement}"
        query.run
      end
    end

    def self.execute(statement)
      TiSqlegalize.database.execute statement
    end
  end
end

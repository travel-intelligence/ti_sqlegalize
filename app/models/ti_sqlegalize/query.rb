module TiSqlegalize
  class Query
    @queue = :query

    attr_accessor :id, :statement, :status

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
      { status: status, statement: statement }
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
      Resque.redis.rpush(k, rows) if k
    end

    def initialize(statement)
      @statement = statement.to_s
    end

    def enqueue!
      Resque.enqueue(self.class, id) if id
    end

    def self.find(id)
      k = meta_key id
      m = Resque.redis.get(k) if k
      if m
        meta = MultiJson.load m
        query = new(meta['statement'])
        query.id = id
        query.status = meta['status'].to_sym
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
        cursor = execute(query.statement)
        cursor.each_slice(1000) do |rows|
          query << rows
        end
        query.status = :finished
        query.save!
      end
    end

    def self.execute(statement)
      TiSqlegalize.database.execute statement
    end
  end
end

# encoding: utf-8
require 'active_model'

module TiSqlegalize
  class SchemaDirectory
    include ActiveModel::Model

    class LoadingError < StandardError
    end

    attr_accessor :schemas

    delegate :size, :[], to: :schemas

    def self.load(file)
      json = begin
        ActiveSupport::JSON.decode File.read(file)
      rescue JSON::ParserError, Errno::ENOENT => e
        raise LoadingError.new(e)
      end

      sd = json['schemas'].flat_map do |schema|
             tables = (schema['tables'] || []).flat_map do |table|
                        columns = (table['columns'] || []).flat_map do |column|
                                    c = TiSqlegalize::Column.new(column)
                                    c.valid? ? [c] : []
                                  end
                        t = TiSqlegalize::Table.new(table.merge({ columns: columns}))
                        t.valid? ? [t] : []
                      end
             s = TiSqlegalize::Schema.new(schema.merge({ tables: tables }))
             s.valid? ? [s] : []
           end

      new(schemas: Hash[sd.map { |d| [d.id, d] }])
    end

    def initialize(attributes={})
      super
      @schemas ||= {}
    end

    def find_table(id)
      @schemas.map do |_,s|
        s.tables.find { |t| t.id == id }
      end.find { |t| t }
    end

    def all
      @schemas.values
    end
  end
end

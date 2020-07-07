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
                        columns = unless table.key?('layout')
                          table['columns']
                        else
                          dirname = File.dirname(file)
                          layout = begin
                                     ActiveSupport::JSON.decode File.read(File.join(dirname, table['layout']))
                                   rescue JSON::ParserError, Errno::ENOENT => e
                                     raise LoadingError.new(e)
                                   end
                          table.delete('layout')
                          layout['columns']
                        end
                        
                        checked = (columns || []).flat_map do |column|
                            domain = column['domain']
                            d = TiSqlegalize::Domain.find(domain)
                            c = TiSqlegalize::Column.new(
                                  name: column['name'], domain: d
                                )
                            c.valid? ? [c] : []
                        end
                        
                        t = TiSqlegalize::Table.new(table.merge({ columns: checked}))
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

    def find_table_schema(table_id)
      _, schema = @schemas.find do |_,s|
                    s.tables.find { |t| t.id == table_id }
                  end
      schema
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

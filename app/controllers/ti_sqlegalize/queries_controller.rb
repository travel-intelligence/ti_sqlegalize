require 'sqliterate'

module TiSqlegalize
  class QueriesController < ApplicationController
    def create
      query = params['queries']
      return invalid_params unless query && query.is_a?(Hash)
      sql = query['sql']
      return invalid_params unless sql && sql.is_a?(String)
      ast = SQLiterate::QueryParser.new.parse sql
      return invalid_params unless ast

      id = SecureRandom.hex(16)
      href = query_url(id)
      rep = {
        queries: {
          id: id,
          href: href,
          sql: sql,
          tables: ast.tables
        }
      }
      response.headers['Location'] = href
      render_api json: rep, status: 201
    end

    def show
      render_api json: {}, status: 204
    end
  end
end

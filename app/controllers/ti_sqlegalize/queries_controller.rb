require 'sqliterate'
require 'resque'

module TiSqlegalize
  class QueriesController < TiSqlegalize::ApplicationController
    ensure_signed_in

    def create
      sql = validate_param_sql

      parser = TiSqlegalize.validator.call

      validation = parser.parse sql, TiSqlegalize.schemas.call

      if validation.valid?
        query = Query.new validation.sql
        query.create!
        query.enqueue!

        render_create query
      else
        render_validation_error validation
      end
    end

    def show
      id = params[:id]
      offset = [params[:offset].to_i, 0].max
      limit = [[params[:limit].to_i, 1].max, 10000].min

      query = Query.find(id)
      if query
        rep = {
          queries: {
            id: id,
            href: query_url(id),
            status: query.status,
            message: query.message,
            offset: offset,
            limit: limit,
            quota: query.quota,
            count: query.count,
            schema: query.schema,
            rows: query[offset, limit]
          }
        }
        render_api json: rep, status: 200
      else
        render_api json: {}, status: 404
      end
    end

    private

    def validate_param_sql
      queries = params['queries']
      raise InvalidParams unless queries && queries.is_a?(Hash)
      sql = queries['sql']
      raise InvalidParams unless sql && sql.is_a?(String)
      sql
    end

    def render_create(query)
      href = query_url(query.id)
      rep = {
        queries: {
          id: query.id,
          href: href,
          sql: query.statement
        }
      }
      response.headers['Location'] = href
      render_api json: rep, status: 201
    end

    def render_validation_error(validation)
      rep = {
        errors: [{
          detail: validation.hint
        }]
      }
      render_api json: rep, status: 400
    end
  end
end

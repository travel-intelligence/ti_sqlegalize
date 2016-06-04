# encoding: utf-8
require 'sqliterate'
require 'resque'

module TiSqlegalize
  class QueriesController < TiSqlegalize::ApplicationController
    ensure_signed_in

    before_action do
      @q_offset = [params.fetch(:offset, 0).to_i, 0].max
      @q_limit = [
          [params.fetch(:limit, 1).to_i, 1].max,
          TiSqlegalize::Config.max_body_limit
        ].min
    end

    def create
      validate_create!

      parser = TiSqlegalize.validator.call
      schemas = TiSqlegalize.schemas.all

      validation = parser.parse @query_sql, schemas

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
      validate_show!

      query = Query.find @query_id

      render_show query
    end

    private

    def validate_show!
      permitted = params.permit(:id)
      @query_id = permitted[:id]
      raise InvalidParams unless @query_id
    end

    def validate_create!
      permitted = params.require(:queries).permit(:sql)
      @query_sql = permitted[:sql]
      raise InvalidParams unless @query_sql
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

    def render_show(query)
      if query
        rep = {
          queries: {
            id: query.id,
            href: query_url(query.id),
            status: query.status,
            message: query.message,
            offset: @q_offset,
            limit: @q_limit,
            quota: query.quota,
            count: query.count,
            schema: query.schema.map { |c| [c.name, c.domain.primitive] },
            rows: query[@q_offset, @q_limit]
          }
        }
        render_api json: rep, status: 200
      else
        render_api json: {}, status: 404
      end
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

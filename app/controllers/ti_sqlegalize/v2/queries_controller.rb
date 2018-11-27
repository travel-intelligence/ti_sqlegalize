# encoding: utf-8
module TiSqlegalize
module V2

  class QueriesController < TiSqlegalize::QueriesController

  private

    # Register here all the DB error messages we know of, so that we can translate them into nice API messages.
    DB_TO_API_MESSAGES = {
      'ORDER BY without LIMIT currently not supported' => 'Must use LIMIT with ORDER BY'
    }

    def validate_create!
      permitted = params.require(:data).permit(:type, attributes: [ :sql ])
      raise InvalidParams unless permitted[:type] == 'query'
      @query_sql = permitted[:attributes][:sql]
      raise InvalidParams unless @query_sql
    end

    def href(query)
      v2_query_url(query.id)
    end

    def query_to_jsonapi(query)
      query_attributes = {
        sql: query.statement,
        status: query.status
      }
      query_attributes[:message] = DB_TO_API_MESSAGES[query.message] if !query.message.empty? && DB_TO_API_MESSAGES.key?(query.message)
      json = {
        data: {
          type: 'query',
          id: query.id,
          attributes: query_attributes,
          links: {
            self: href(query)
          }
        }
      }
      json[:data].merge!(
        relationships: {
          result: {
            links: {
              related: v2_query_result_url(query.id)
            }
          }
        }
      ) if query.status == :finished
      json
    end

    def render_create(query)
      response.headers['Location'] = href(query)
      render_api json: query_to_jsonapi(query), status: 201
    end

    def render_show(query)
      if query
        render_api json: query_to_jsonapi(query), status: 200
      else
        render_not_found
      end
    end
  end

end
end

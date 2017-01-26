# encoding: utf-8
module TiSqlegalize
module V2

  class QueriesController < TiSqlegalize::QueriesController

  private

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
      query_attributes[:message] = query.message unless query.message.empty?
      {
        data: {
          type: 'query',
          id: query.id,
          attributes: query_attributes,
          links: {
            self: href(query)
          }
        }.merge(
          if query.status == :finished
            {
              relationships: {
                result: {
                  links: {
                    related: v2_query_result_url(query.id)
                  }
                }
              }
            }
          else
            {}
          end
        )
      }
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

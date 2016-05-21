
module TiSqlegalize
module V2

  class QueriesController < TiSqlegalize::QueriesController

  private

    def validate_create
      @query_data = params.require(:data).permit(:type, attributes: [ :sql ])
      raise InvalidParams unless @query_data[:type] == 'query' && \
                                 @query_data[:attributes][:sql]
    end

    def query_sql
      @query_data[:attributes][:sql]
    end

    def href(query)
      v2_query_url(query.id)
    end

    def jsonapi(query)
      {
        data: {
          type: 'query',
          id: query.id,
          attributes: {
            sql: query.statement,
            status: query.status
          },
          links: {
            :self => href(query)
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
      render_api json: jsonapi(query), status: 201
    end

    def render_show(query)
      if query
        render_api json: jsonapi(query), status: 200
      else
        render_not_found
      end
    end
  end

end
end

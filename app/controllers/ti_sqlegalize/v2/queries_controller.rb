
module TiSqlegalize
module V2

  class QueriesController < TiSqlegalize::QueriesController

  private

    def validate_param_sql
      data = params['data']
      raise InvalidParams unless data && data.is_a?(Hash)
      type = data['type']
      raise InvalidParams unless type == 'query'
      attributes = data['attributes']
      raise InvalidParams unless attributes && attributes.is_a?(Hash)
      sql = attributes['sql']
      raise InvalidParams unless sql && sql.is_a?(String)
      sql
    end

    def render_create(query)
      href = v2_query_url(query.id)
      rep = {
        data: {
          type: 'query',
          id: query.id,
          attributes: {
            sql: query.statement,
            status: query.status
          },
          links: {
            :self => href
          }
        }
      }
      response.headers['Location'] = href
      render_api json: rep, status: 201
    end
  end

end
end

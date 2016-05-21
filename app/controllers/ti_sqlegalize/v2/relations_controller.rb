
module TiSqlegalize
module V2

  class RelationsController < TiSqlegalize::ApplicationController
    ensure_signed_in

    def show
      id = params[:query_id]

      query = Query.find(id)

      render_show query
    end

  private

    def href(query)
      v2_query_result_url(query.id)
    end

    def jsonapi(query)
      heading = query.schema.map do |name, type|
        [ "heading_#{name}", {
          links: {
            related: v2_query_result_heading_url(query.id, name)
          },
          data: {
            type: 'domain',
            id: type
          }
        }]
      end

      {
        data: {
          type: 'relation',
          id: query.id,
          attributes: {
            sql: query.statement,
            heading: query.schema.map { |f| f.first }
          },
          relationships: {
            body: {
              links: {
                related: v2_query_result_body_url(query.id)
              }
            }
          }.merge(Hash[heading]),
          links: {
            :self => href(query)
          }
        }
      }
    end

    def render_show(query)
      if query
        if query.status == :finished
          render_api json: jsonapi(query), status: 200
        else
          render_conflict
        end
      else
        render_not_found
      end
    end
  end

end
end

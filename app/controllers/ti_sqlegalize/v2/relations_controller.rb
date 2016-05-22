# encoding: utf-8
module TiSqlegalize
module V2

  class RelationsController < TiSqlegalize::ApplicationController

    include TiSqlegalize::V2::Concerns::DomainRepresentable

    ensure_signed_in

    before_action do
      permitted = params.permit(:query_id)
      @query_id = permitted[:query_id]
      raise InvalidParams unless @query_id
    end

    def show
      query = Query.find @query_id

      render_show query
    end

  private

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

      included = query.schema.map { |_, type| type }.uniq.map do |type|
        domain = Domain.find(type)
        domain_jsonapi(domain, relationships: false)
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
            :self => v2_query_result_url(query.id)
          }
        },
        included: included
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

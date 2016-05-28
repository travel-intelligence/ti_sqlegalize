# encoding: utf-8
module TiSqlegalize
module V2

  class DomainsController < TiSqlegalize::ApplicationController
    ensure_signed_in

    before_action do
      permitted = params.permit(:id)
      @domain_id = permitted[:id]
      raise InvalidParams unless @domain_id
    end

    def show
      domain = begin
        Domain.find @domain_id
      rescue Domain::UnknownDomain
        nil
      end

      if domain
        render_api json: jsonapi(domain), status: 200
      else
        render_not_found
      end
    end

    private

    def jsonapi(domain)
      {
        data: {
          type: 'domain',
          id: domain.id,
          attributes: {
            name: domain.name,
            primitive: domain.primitive
          },
          relationships: {
            relations: {
              links: {
                related: v2_domain_relations_url(domain.id)
              }
            }
          },
          links: {
            :self => v2_domain_url(domain.id)
          }
        }
      }
    end
  end

end
end

# encoding: utf-8
module TiSqlegalize
module V2
module Concerns

module DomainRepresentable
  extend ActiveSupport::Concern

  def domain_jsonapi(domain, relationships: true)
    {
      data: {
        type: 'domain',
        id: domain.id,
        attributes: {
          name: domain.name,
          primitive: domain.primitive
        },
        links: {
          :self => v2_domain_url(domain.id)
        }
      }.merge(
        if relationships
          {
            relationships: {
              relations: {
                links: {
                  related: v2_domain_relations_url(domain.id)
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
end

end
end
end

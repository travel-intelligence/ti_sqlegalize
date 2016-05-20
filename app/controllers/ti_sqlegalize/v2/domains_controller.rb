# encoding: utf-8
module TiSqlegalize
module V2

  class DomainsController < TiSqlegalize::ApplicationController

    include TiSqlegalize::V2::Concerns::DomainRepresentable

    ensure_signed_in

    before_action do
      permitted = params.permit(:id)
      @domain_id = permitted[:id]
    end

    def show
      raise InvalidParams unless @domain_id

      domain = begin
        Domain.find @domain_id
      rescue Domain::UnknownDomain
        nil
      end

      if domain
        render_api json: domain_to_jsonapi(domain), status: 200
      else
        render_not_found
      end
    end
  end

end
end

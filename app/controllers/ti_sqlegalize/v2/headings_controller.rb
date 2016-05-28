# encoding: utf-8
module TiSqlegalize
module V2

  class HeadingsController < TiSqlegalize::ApplicationController

    include TiSqlegalize::V2::Concerns::DomainRepresentable

    ensure_signed_in

    before_action do
      permitted = params.permit(:query_id, :attr_id)
      @query_id = permitted[:query_id]
      @attr_id = permitted[:attr_id]
      raise InvalidParams unless @query_id && @attr_id
    end

    def show_by_query
      query = Query.find @query_id

      if query
        if query.status == :finished

          attribute = query.schema.find { |name,_| name == @attr_id }

          domain = Domain.find attribute.last

          render_api json: domain_jsonapi(domain), status: 200
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

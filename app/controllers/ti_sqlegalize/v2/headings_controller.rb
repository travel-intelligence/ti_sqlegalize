# encoding: utf-8
module TiSqlegalize
module V2

  class HeadingsController < TiSqlegalize::ApplicationController

    include TiSqlegalize::V2::Concerns::DomainRepresentable

    ensure_signed_in

    before_action do
      permitted = params.permit(:query_id, :relation_id, :attr_id)
      @query_id = permitted[:query_id]
      @relation_id = permitted[:relation_id]
      @attr_id = permitted[:attr_id]
    end

    def show_by_query
      raise InvalidParams unless @query_id && @attr_id

      query = Query.find @query_id

      if query
        if query.status == :finished

          column = query.schema.find { |c| c.name == @attr_id }
          domain = column && column.domain

          if domain
            render_api json: domain_to_jsonapi(domain), status: 200
          else
            render_not_found
          end
        else
          render_conflict
        end
      else
        render_not_found
      end
    end

    def show_by_relation
      raise InvalidParams unless @relation_id && @attr_id

      table = begin
        Table.find @relation_id
      rescue Table::UnknownTable
        nil
      end

      column = table && current_user.can_read_schema?(table.schema) \
                     && table.columns.find { |c| c.name == @attr_id }
      domain = column && column.domain

      if domain
        render_api json: domain_to_jsonapi(domain), status: 200
      else
        render_not_found
      end
    end
  end

end
end

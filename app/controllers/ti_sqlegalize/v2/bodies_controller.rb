# encoding: utf-8
module TiSqlegalize
module V2

  class BodiesController < TiSqlegalize::ApplicationController
    ensure_signed_in

    before_action do
      permitted = params.permit(:query_id, :q_offset, :q_limit)
      @query_id = permitted[:query_id]
      @q_offset = [permitted.fetch(:q_offset, 0).to_i, 0].max
      @q_limit = [
          [permitted.fetch(:q_limit, 1).to_i, 1].max,
          TiSqlegalize::Config.max_body_limit
        ].min
      raise InvalidParams unless @query_id
    end

    def show
      query = Query.find @query_id

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

  private

    def jsonapi(query)
      {
        meta: {
          offset: @q_offset,
          limit: @q_limit,
          count: query.count
        },
        data: {
          type: 'body',
          id: query.id,
          attributes: {
            tuples: query[@q_offset, @q_limit]
          },
          relationships: {
            relation: {
              links: {
                related: v2_query_result_url(query.id)
              }
            }
          },
          links: {
            :self => v2_query_result_body_url(query.id)
          }
        }
      }
    end
  end

end
end

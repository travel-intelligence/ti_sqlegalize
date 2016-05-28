# encoding: utf-8
module TiSqlegalize
module V2

  class BodiesController < TiSqlegalize::ApplicationController
    ensure_signed_in

    before_action do
      permitted = params.permit(:query_id, :relation_id, :q_offset, :q_limit)
      @query_id = permitted[:query_id]
      @relation_id = permitted[:relation_id]
      @q_offset = [permitted.fetch(:q_offset, 0).to_i, 0].max
      @q_limit = [
          [permitted.fetch(:q_limit, 1).to_i, 1].max,
          TiSqlegalize::Config.max_body_limit
        ].min
    end

    def show_by_query
      raise InvalidParams unless @query_id

      query = Query.find @query_id

      if query
        if query.status == :finished
          render_api json: query_to_jsonapi(query), status: 200
        else
          render_conflict
        end
      else
        render_not_found
      end
    end

    def show_by_relation
      raise InvalidParams unless @relation_id

      table = Table.find @relation_id

      if table
        render_api json: table_to_jsonapi(table), status: 200
      else
        render_not_found
      end
    end

  private

    def query_to_jsonapi(query)
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

    def table_to_jsonapi(table)
      # Not implemented
      {
        meta: {
          offset: @q_offset,
          limit: @q_limit,
          count: 0
        },
        data: {
          type: 'body',
          id: table.id,
          attributes: {
            tuples: []
          },
          relationships: {
            relation: {
              links: {
                related: v2_relation_url(table.id)
              }
            }
          },
          links: {
            :self => v2_relation_body_url(table.id)
          }
        }
      }
    end
  end

end
end

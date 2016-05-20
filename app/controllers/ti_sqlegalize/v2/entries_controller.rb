# encoding: utf-8
module TiSqlegalize
module V2

  class EntriesController < TiSqlegalize::ApplicationController
    ensure_signed_in

    def show
      render_api json: entry_to_jsonapi, status: 200
    end

    private

    def entry_to_jsonapi
      {
        data: {
          type: 'entry',
          id: '1',
          relationships: {
            queries: {
              links: {
                related: v2_queries_url
              }
            },
            schemas: {
              links: {
                related: v2_schemas_url
              }
            }
          },
          links: {
            :self => v2_entry_url
          }
        }
      }
    end
  end

end
end


module TiSqlegalize
module V2

  class EntriesController < TiSqlegalize::ApplicationController
    ensure_signed_in

    def show
      rep = {
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
      render_api json: rep, status: 200
    end
  end

end
end

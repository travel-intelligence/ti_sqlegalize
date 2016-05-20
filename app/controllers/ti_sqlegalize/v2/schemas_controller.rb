
module TiSqlegalize
module V2

  class SchemasController < TiSqlegalize::ApplicationController
    ensure_signed_in

    def index
      rep = {
      }
      render_api json: rep, status: 200
    end

    def show
      rep = {
      }
      render_api json: rep, status: 200
    end
  end

end
end

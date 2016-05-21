
module TiSqlegalize
module V2

  class BodiesController < TiSqlegalize::ApplicationController
    ensure_signed_in

    def show
      render_not_found
    end
  end

end
end

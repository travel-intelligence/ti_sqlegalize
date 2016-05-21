
module TiSqlegalize
module V2

  class HeadingsController < TiSqlegalize::ApplicationController
    ensure_signed_in

    def show
      render_not_found
    end
  end

end
end

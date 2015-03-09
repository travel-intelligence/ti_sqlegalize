require 'rails-api/action_controller/api'
require 'ti_rails_auth/controller'

module TiSqlegalize
  class ApplicationController < ActionController::API

    include ActionController::MimeResponds
    include TiRailsAuth::Controller

    rescue_from Exception, with: :exception_handler

    protected

    def render_error(code)
      render_api json: {}, status: code
    end

    def invalid_params
      render_error 400
    end

    def exception_handler(exception)
      msg = ["#{exception.class}: #{exception}"] + exception.backtrace.take(5)
      logger.error msg.join("\n")
      respond_to do |format|
        format.html { render text: 'Internal Server Error', status: 500 }
        format.json { render json: {}, status: 500 }
        format.jsonapi { render json: {}, status: 500 }
      end
    end

    def render_api(options)
      response.headers['Link'] =
        "<#{profile_url}>; rel=\"profile\""
      respond_to do |format|
        format.json { render options }
        format.jsonapi { render options }
        format.all { render options.merge(content_type: Mime::JSON) }
      end
    end
  end
end

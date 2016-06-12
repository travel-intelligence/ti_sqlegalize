# encoding: utf-8
require 'rails-api/action_controller/api'

module TiSqlegalize

  class ApplicationController < ActionController::API

    include ActionController::MimeResponds

    class InvalidParams < StandardError
    end

    rescue_from InvalidParams, with: :render_invalid_params
    rescue_from ActionController::ParameterMissing, with: :render_invalid_params
    rescue_from Exception, with: :render_exception if Rails.env.production?

    protected

    def self.ensure_signed_in
      include Config.auth_mixin

      before_filter do
        render_invalid_credentials unless authenticate
      end
    end

    def render_error(status, code=nil)
      rep = {
        errors: [
          {
            status: status.to_s,
          }.merge(
            code ? { code: code.to_s } : {}
          )
        ]
      }
      render_api json: rep, status: status
    end

    def render_invalid_params
      render_error 400, "invalid parameters"
    end

    def render_not_found
      render_error 404, "not found"
    end

    def render_conflict
      render_error 409, "conflict"
    end

    def render_internal_error
      render_error 500, "internal error"
    end

    def render_invalid_credentials
      render_error 401, "invalid credentials"
    end

    def render_exception(exception)
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

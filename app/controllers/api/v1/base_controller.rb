require "digest"

class Api::V1::BaseController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  class BadRequest < StandardError; end

  before_action :authenticate_api!

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::ParameterMissing, with: :render_bad_request
  rescue_from BadRequest, with: :render_bad_request

  private

  def authenticate_api!
    authenticated = authenticate_with_http_token do |token, _options|
      valid_token?(token)
    end

    render_error("Unauthorized", :unauthorized) unless authenticated
  end

  def valid_token?(token)
    expected_token = Rails.application.credentials.api_token.to_s
    return false if expected_token.blank?

    ActiveSupport::SecurityUtils.secure_compare(
      Digest::SHA256.hexdigest(token),
      Digest::SHA256.hexdigest(expected_token)
    )
  end

  def render_error(messages, status)
    render json: { errors: Array(messages) }, status: status
  end

  def render_not_found(error)
    render_error(error.message, :not_found)
  end

  def render_bad_request(error)
    render_error(error.message, :bad_request)
  end
end

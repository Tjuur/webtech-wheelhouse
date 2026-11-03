class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  allow_browser versions: :modern

  after_action :verify_pundit_authorization

  rescue_from Pundit::NotAuthorizedError, with: :render_forbidden

  private

  def pundit_user
    Current.user
  end

  def verify_pundit_authorization
    return if response.redirect? && Current.user.nil?

    if action_name == "index"
      verify_policy_scoped
    else
      verify_authorized
    end
  end

  def render_forbidden
    render "errors/forbidden", status: :forbidden
  end
end

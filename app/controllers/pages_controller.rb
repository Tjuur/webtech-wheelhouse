class PagesController < ApplicationController
  allow_unauthenticated_access

  skip_after_action :verify_pundit_authorization

  def home
  end

  def visit
  end

  def about
  end
end

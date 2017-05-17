class ApplicationController < ActionController::Base
  include CredentialsHelper
  include ApplicationHelper
  include UsersHelper
  include OrganizationsHelper

  before_action :check_content_type

  protect_from_forgery with: :null_session

  rescue_from ActiveRecord::RecordInvalid, with: :invalid_record_exception

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found_exception

  private

  def check_content_type
    error!(415, error: 'Unsupported Media Type') unless json?
  end

  def invalid_record_exception(ex)
    error! 422, message: ex.record.errors
  end

  def record_not_found_exception(ex)
    error! 404, message: ex.message
  end
end

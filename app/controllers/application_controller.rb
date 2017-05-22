class ApplicationController < ActionController::Base
  include CredentialsHelper
  include ApplicationHelper
  include UsersHelper
  include OrganizationsHelper

  protect_from_forgery with: :null_session

  rescue_from ActiveRecord::RecordInvalid, with: :invalid_record_exception

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found_exception

  rescue_from NoMethodError, with: :display_nil_exception

  if Rails.env.production?
    rescue_from Exception, with: :display_nil_exception
  end

  private

  def display_nil_exception(ex)
    error! 500, message: (Rails.env.production? ? 'Internal Server Error' : ex.message)
  end

  def invalid_record_exception(ex)
    error! 422, message: ex.record.errors
  end

  def record_not_found_exception(ex)
    error! 404, message: ex.message
  end
end

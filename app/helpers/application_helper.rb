module ApplicationHelper
  def error!(*args)
    response = args.extract_options!
    render json: response, status: args.first
  end

  def render_ok(message = nil)
    render json: { message: (message || 'OK') }, status: 200
  end

  def json?
    request.accept.eql?('application/json')
  end

  def limit
    params[:limit] || 25
  end

  private

  def admin_authorized?
    error! 401, error: 'Unauthorized' unless admin?
  end

  def user_authorized?
    error! 401, error: 'Unauthorized' unless current_user
  end

  def updatable_field
    { params[:field].to_sym => params[:value] }
  end
end

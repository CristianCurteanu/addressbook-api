module UsersHelper
  def admin?
    current_user && current_user.type.name == 'ADMIN'
  end

  def current_user
    authorization ||= AuthorizationService.call(request.headers)
    return authorization.result if authorization.success?
  end

  def format_user(user)
    datas = user.attributes.slice(*user_data.map(&:to_s))
                .merge(type: user.type.name,
                       organizations: user.organizations.as_json(only: [:id, :name]))
    datas.delete_if { |_k, v| v.nil? }
  end

  def user_data
    [:id, :email, :first_name, :middle_name, :last_name, :date_of_birth, :avatar]
  end
end

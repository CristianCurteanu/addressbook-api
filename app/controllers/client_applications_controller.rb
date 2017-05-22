class ClientApplicationsController < ApplicationController
  before_action do
    error!(400, {error: 'Provide an email'}) unless params[:email]
  end

  def create
    uuid = SecureRandom.uuid
    datas = { email: params[:email],
              uuid:  uuid,
              key:   JWT.encode(params[:email], uuid) }
    render json: datas.slice(:uuid) if Client.create!(datas)
  end
end
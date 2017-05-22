module CredentialsHelper
  def credentials
    { email: params[:email],
      password: JWT.decode(params[:password], client_key)[0] }
  end

  def client_key
    Client.find_by_uuid(request.cookies['uuid']).key
  end
end

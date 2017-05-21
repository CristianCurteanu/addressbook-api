Apipie.configure do |config|
  config.app_name                = "AddressBook API"
  config.api_base_url            = ""
  config.api_routes              = Rails.application.routes
  config.doc_base_url            = "/documentation"
  config.validate_value          = false
  config.validate_presence       = false
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
end

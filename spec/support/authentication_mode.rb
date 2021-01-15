RSpec.configure do |configure|
  # Allow examples to be tagged with "authentication_mode: :magic_link".
  # Allow examples to be tagged with "authentication_mode: :dfe_signin".
  # Allow examples to be tagged with "authentication_mode: :persona".
  # This will then reload routes for that mode
  configure.around :each do |example|
    new_authentication_mode = example.metadata.dig(:authentication_mode).to_s

    if new_authentication_mode.present?
      old_value = Settings.authentication.mode
      Settings.authentication.mode = new_authentication_mode
      Rails.application.reload_routes!

      example.run

      Settings.authentication.mode = old_value
      Rails.application.reload_routes!
    else
      example.run
    end
  end
end

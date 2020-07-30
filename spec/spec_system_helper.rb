# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
require "capybara/cuprite"

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)

require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

# Add the site_prism dir to autoloads so that they get loaded up automatically.
# This may be frowned-upon in Rails, but doing it this way can help
# dependencies get sorted out better than if they're all required in at once by
# walking the directory structure, so should be ok in the contexts of tests.
ActiveSupport::Dependencies.autoload_paths +=
  [Rails.root.join("spec/site_prism")]

Capybara.javascript_driver = :cuprite
Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(app,
                                window_size: [1200, 800],
                                browser_options: { "ignore-certificate-errors" => nil })
end
Capybara.app_host = 'https://localhost:3000'

# Make server accessible from the outside world
Capybara.server_host = "0.0.0.0"
# Use a hostname that could be resolved in the internal Docker network
# NOTE: Rails overrides Capybara.app_host in Rails <6.1, so we have
# to store it differently
CAPYBARA_APP_HOST = `hostname`.strip&.downcase || "0.0.0.0"
# In Rails 6.1+ the following line should be enough
# Capybara.app_host = "http://#{`hostname`.strip&.downcase || "0.0.0.0"}"


# Usually, especially when using Selenium, developers tend to increase the max wait time.
# With Cuprite, there is no need for that.
# We use a Capybara default value here explicitly.
Capybara.default_max_wait_time = 5

RSpec.configure do |config|
  config.prepend_before(:each, type: :system) do
    WebMock.disable!

    # Rails sets host to `127.0.0.1` for every test by default.
    # That won't work with a remote browser.
    host! 'https://localhost:3000'
    # Use JS driver always
    driven_by Capybara.javascript_driver
  end
end

OmniAuth.config.logger = Rails.logger

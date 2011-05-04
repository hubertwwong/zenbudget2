# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Zenbudget::Application.initialize!

# DELETE THE BELOW. this was to fix issues for SSL for jquery.
# require 'openssl'
# OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

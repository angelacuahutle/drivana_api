class ApplicationController < ActionController::Base
    # Skip CSRF verification for requests with a JSON format
    skip_before_action :verify_authenticity_token, if: :json_request?
  
    private
  
    def json_request?
      request.format.json?
    end
  end
  

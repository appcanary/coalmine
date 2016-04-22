class ErrorsController < ApplicationController
  skip_before_filter :set_onboarded, :require_login
end

class ErrorsController < ApplicationController
  skip_before_filter :set_onboarded 
end

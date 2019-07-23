class Dashboard::BaseController < ApplicationController
  before_action :require_merchant, except: [:fulfill]
  before_action :merchant_or_admin, only: [:fulfill]

end
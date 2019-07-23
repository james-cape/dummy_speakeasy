class Admin::ItemsController < Admin::BaseController
  def index
    @merchant = User.find(params[:merchant_id])
    @items = @merchant.items
    render :'/dashboard/items/index'
  end
end
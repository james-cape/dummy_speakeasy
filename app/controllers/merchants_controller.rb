class MerchantsController < ApplicationController
  def index
    if current_admin?
      @merchants = User.where(role: :merchant)
    else
      @merchants = User.active_merchants
    end
    @top_three_merchants_by_revenue = @merchants.top_merchants_by_revenue(3)
    @top_three_merchants_by_fulfillment = @merchants.top_merchants_by_fulfillment_time(3)
    @bottom_three_merchants_by_fulfillment = @merchants.bottom_merchants_by_fulfillment_time(3)
    @top_states_by_order_count = User.top_address_states_by_order_count(3)
    @top_cities_by_order_count = User.top_address_cities_by_order_count(3)
    @top_orders_by_items_shipped = Order.sorted_by_items_shipped(3)
  end
end

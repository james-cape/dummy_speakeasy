class Address < ApplicationRecord
  validates_presence_of :user_id, :street, :city, :state, :zip_code

  belongs_to :user
  has_many :orders

  def in_completed_order?
    # orders.where(status: "packaged").or(orders.where(status: "shipped")).count > 0
    orders.count > 0
  end
end

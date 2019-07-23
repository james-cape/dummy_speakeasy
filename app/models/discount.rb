class Discount < ApplicationRecord
  belongs_to :user
  # validates_presence_of :discount_amount
  # validates_presence_of :minimum_quantity
  validates_presence_of :description

  validates :discount_amount,
    presence: true,
    numericality: {
      only_integer: false,
      greater_than: 0
    }

  validates :minimum_quantity,
    presence: true,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0
    }
end

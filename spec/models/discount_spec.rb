require 'rails_helper'

RSpec.describe Discount, type: :model do
  describe 'validations' do
    it { should validate_presence_of :discount_amount }
    it { should validate_numericality_of(:discount_amount).is_greater_than(0) }

    it { should validate_presence_of :minimum_quantity }
    it { should validate_numericality_of(:minimum_quantity).only_integer }
    it { should validate_numericality_of(:minimum_quantity).is_greater_than_or_equal_to(0) }

    it { should validate_presence_of :description}
  end

  describe 'relationships' do
    it { should belong_to :user }
  end

  describe 'creation exists' do
    it 'can create a discount' do
      merchant = create(:user, role: 1)
      discount = create(:discount, user: merchant)

      expect(discount.description).to eq("Discount description 1")
      expect(discount.minimum_quantity).to eq(4)
      expect(discount.discount_amount).to eq(3)
      expect(discount.user).to eq(merchant)
    end
  end
end

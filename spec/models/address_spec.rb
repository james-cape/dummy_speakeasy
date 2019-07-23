require 'rails_helper'

describe Address, type: :model do
  describe "validations" do
    # it {should validate_presence_of(:user_id)}
    # it {should validate_presence_of(:street)}
    # it {should validate_presence_of(:city)}
    # it {should validate_presence_of(:state)}
    # it {should validate_presence_of(:zip_code)}
    # ^^ No validations because user must be able to delete all their addresses
  end

  describe 'instance methods' do
    before :each do
      @user = create(:user)
      @address_1 = create(:address, user: @user)
      @address_2 = create(:address, user: @user)
      @address_3 = create(:address, user: @user)
      @address_4 = create(:address, user: @user)
      @address_5 = create(:address, user: @user)
      @item_1 = create(:item)
      @item_2 = create(:item)
      yesterday = 1.day.ago

      @order = create(:order, user: @user, created_at: yesterday, address_id: @address_1.id) #pending
      @oi_1 = create(:order_item, order: @order, item: @item_1, price: 1, quantity: 1, created_at: yesterday, updated_at: yesterday)
      @oi_2 = create(:fulfilled_order_item, order: @order, item: @item_2, price: 2, quantity: 1, created_at: yesterday, updated_at: 2.hours.ago)

      @merchant = create(:merchant)
      @i1, @i2 = create_list(:item, 2, user: @merchant)
      @o1, @o2 = create_list(:order, 2)
      @o3 = create(:packaged_order, address_id: @address_2.id)
      @o4 = create(:shipped_order, address_id: @address_3.id)
      @o5 = create(:cancelled_order, address_id: @address_4.id)
      create(:order_item, order: @o1, item: @i1, quantity: 1, price: 2)
      create(:order_item, order: @o1, item: @i2, quantity: 2, price: 2)
      create(:order_item, order: @o2, item: @i2, quantity: 4, price: 2)
      create(:order_item, order: @o3, item: @i1, quantity: 4, price: 2)
      create(:order_item, order: @o4, item: @i2, quantity: 5, price: 2)
      create(:order_item, order: @o5, item: @i1, quantity: 5, price: 2)
    end

    it '.in_completed_order?' do
      expect(@address_1.in_completed_order?).to eq(true) # order is pending
      expect(@address_2.in_completed_order?).to eq(true)  # order is packaged
      expect(@address_3.in_completed_order?).to eq(true)  # order is shipped
      expect(@address_4.in_completed_order?).to eq(true) # order is cancelled
      expect(@address_5.in_completed_order?).to eq(false) # not in an order
    end
  end

  describe 'instance methods' do
    before :each do
      @u1 = create(:user)
      @u2 = create(:user)
      @u3 = create(:user)
      @u4 = create(:user)
      @u5 = create(:user)
      @u6 = create(:user)
      @m1 = create(:merchant)

      @a1a = create(:address, user_id: @u1.id, state: "CO", city: "Anywhere", nickname: "home")
      @a2a = create(:address, user_id: @u2.id, state: "OK", city: "Tulsa", nickname: "home")
      @a3a = create(:address, user_id: @u3.id, state: "IA", city: "Anywhere", nickname: "home")
      @a4a = create(:address, user_id: @u4.id, state: "IA", city: "Des Moines", nickname: "home")
      @a5a = create(:address, user_id: @u5.id, state: "IA", city: "Des Moines", nickname: "home")
      @a6a = create(:address, user_id: @u6.id, state: "IA", city: "Des Moines", nickname: "home")

      @i1 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i2 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i3 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i4 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i5 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i6 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i7 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i8 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i9 = create(:inactive_item, merchant_id: @m1.id)

      @m2 = create(:merchant)
      @i10 = create(:item, merchant_id: @m2.id, inventory: 20)

      @o1 = create(:shipped_order, user: @u1, address_id: @a3a.id)
      @o2 = create(:shipped_order, user: @u1, address_id: @a3a.id)
      @o3 = create(:shipped_order, user: @u1, address_id: @a3a.id)
      @o4 = create(:shipped_order, user: @u1, address_id: @a3a.id)
      @o5 = create(:shipped_order, user: @u1, address_id: @a1a.id)
      @o7 = create(:shipped_order, user: @u1, address_id: @a1a.id)
      @o7 = create(:shipped_order, user: @u1, address_id: @a1a.id)
      @o7 = create(:shipped_order, user: @u1, address_id: @a2a.id)
      @o7 = create(:shipped_order, user: @u1, address_id: @a2a.id)
      @o7 = create(:shipped_order, user: @u1, address_id: @a4a.id)
      @o7 = create(:shipped_order, user: @u1, address_id: @a5a.id)
      @o6 = create(:cancelled_order, user: @u5, address_id: @a6a.id)

      @oi1 = create(:order_item, item: @i1, order: @o1, quantity: 2, created_at: 1.days.ago)
      @oi2 = create(:order_item, item: @i2, order: @o2, quantity: 8, created_at: 7.days.ago)
      @oi3 = create(:order_item, item: @i2, order: @o3, quantity: 6, created_at: 7.days.ago)
      @oi4 = create(:order_item, item: @i3, order: @o3, quantity: 4, created_at: 6.days.ago)
      @oi5 = create(:order_item, item: @i4, order: @o4, quantity: 3, created_at: 4.days.ago)
      @oi6 = create(:order_item, item: @i5, order: @o5, quantity: 1, created_at: 5.days.ago)
      @oi7 = create(:order_item, item: @i6, order: @o6, quantity: 2, created_at: 3.days.ago)
      @oi1.fulfill
      @oi2.fulfill
      @oi3.fulfill
      @oi4.fulfill
      @oi5.fulfill
      @oi6.fulfill
      @oi7.fulfill
    end
    #
    # it ".top_address_states_by_order_count" do
    #   expect(Address.top_address_states_by_order_count(3)[0].state).to eq("IA")
    #   expect(Address.top_address_states_by_order_count(3)[0].order_count).to eq(6)
    #   expect(Address.top_address_states_by_order_count(3)[1].state).to eq("CO")
    #   expect(Address.top_address_states_by_order_count(3)[1].order_count).to eq(3)
    #   expect(Address.top_address_states_by_order_count(3)[2].state).to eq("OK")
    #   expect(Address.top_address_states_by_order_count(3)[2].order_count).to eq(2)
    # end
    #
    # it ".top_address_cities_by_order_count" do
    #   expect(Address.top_address_cities_by_order_count(3)[0].state).to eq("IA")
    #   expect(Address.top_address_cities_by_order_count(3)[0].city).to eq("Anywhere")
    #   expect(Address.top_address_cities_by_order_count(3)[0].order_count).to eq(4)
    #   expect(Address.top_address_cities_by_order_count(3)[1].state).to eq("CO")
    #   expect(Address.top_address_cities_by_order_count(3)[1].city).to eq("Anywhere")
    #   expect(Address.top_address_cities_by_order_count(3)[1].order_count).to eq(3)
    #   expect(Address.top_address_cities_by_order_count(3)[2].state).to eq("IA")
    #   expect(Address.top_address_cities_by_order_count(3)[2].city).to eq("Des Moines")
    #   expect(Address.top_address_cities_by_order_count(3)[2].order_count).to eq(2)
    # end
  end
end

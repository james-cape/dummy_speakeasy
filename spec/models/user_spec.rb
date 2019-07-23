require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
    it { should validate_presence_of :password }
    it { should validate_presence_of :name }
  end

  describe 'relationships' do
    it { should have_many :orders }
    it { should have_many(:order_items).through(:orders)}
    it { should have_many :items }
    it { should have_many :discounts }
  end

  describe 'roles' do
    it 'can be created as a default user' do
      u1 = create(:user, role: 0)

      expect(u1.role).to eq('default')
      expect(u1.default?).to be_truthy
    end

    it 'can be created as a merchant' do
      u1 = create(:user, role: 1)

      expect(u1.role).to eq('merchant')
      expect(u1.merchant?).to be_truthy
    end

    it 'can be created as an admin' do
      u1 = create(:user, role: 2)

      expect(u1.role).to eq('admin')
      expect(u1.admin?).to be_truthy
    end
  end

  describe 'instance methods' do
    before :each do
      @u1 = create(:user)
      @u2 = create(:user)
      @u3 = create(:user)
      u4 = create(:user)
      u5 = create(:user)
      u6 = create(:user)
      @m1 = create(:merchant)

      @a1a = create(:address, user_id: @u1.id, state: "CO", city: "Anywhere", nickname: "home")
      @a2a = create(:address, user_id: @u2.id, state: "OK", city: "Tulsa", nickname: "home")
      @a3a = create(:address, user_id: @u3.id, state: "IA", city: "Anywhere", nickname: "home")
      @a4a = create(:address, user_id: u4.id, state: "IA", city: "Des Moines", nickname: "home")
      @a5a = create(:address, user_id: u5.id, state: "IA", city: "Des Moines", nickname: "home")
      @a6a = create(:address, user_id: u6.id, state: "IA", city: "Des Moines", nickname: "home")
      @a1b = create(:address, user_id: @u1.id, state: "CO", city: "Anywhere", nickname: "business")
      @a2b = create(:address, user_id: @u2.id, state: "OK", city: "Tulsa", nickname: "business")
      @a3b = create(:address, user_id: @u3.id, state: "IA", city: "Anywhere", nickname: "business")
      @a4b = create(:address, user_id: u4.id, state: "IA", city: "Des Moines", nickname: "business")
      @a5b = create(:address, user_id: u5.id, state: "IA", city: "Des Moines", nickname: "business")
      @a6b = create(:address, user_id: u6.id, state: "IA", city: "Des Moines", nickname: "business")

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

      o1 = create(:shipped_order, user: @u1, address_id: @a1a.id)
      o2 = create(:shipped_order, user: @u2, address_id: @a2a.id)
      o3 = create(:shipped_order, user: @u3, address_id: @a3a.id)
      o4 = create(:shipped_order, user: @u1, address_id: @a4a.id)
      o5 = create(:shipped_order, user: @u1, address_id: @a5a.id)
      o6 = create(:cancelled_order, user: u5, address_id: @a6a.id)
      o7 = create(:order, user: u6)

      @oi1 = create(:order_item, item: @i1, order: o1, quantity: 2, created_at: 1.days.ago)
      @oi2 = create(:order_item, item: @i2, order: o2, quantity: 8, created_at: 7.days.ago)
      @oi3 = create(:order_item, item: @i2, order: o3, quantity: 6, created_at: 7.days.ago)
      @oi4 = create(:order_item, item: @i3, order: o3, quantity: 4, created_at: 6.days.ago)
      @oi5 = create(:order_item, item: @i4, order: o4, quantity: 3, created_at: 4.days.ago)
      @oi6 = create(:order_item, item: @i5, order: o5, quantity: 1, created_at: 5.days.ago)
      @oi7 = create(:order_item, item: @i6, order: o6, quantity: 2, created_at: 3.days.ago)
      @oi1.fulfill
      @oi2.fulfill
      @oi3.fulfill
      @oi4.fulfill
      @oi5.fulfill
      @oi6.fulfill
      @oi7.fulfill
    end

    # it '.active_items' do
    #   expect(@m2.active_items).to eq([@i10])
    #   expect(@m1.active_items).to eq([@i1, @i2, @i3, @i4, @i5, @i6, @i7, @i8])
    # end

    it '.top_items_sold_by_quantity' do
      expect(@m1.top_items_sold_by_quantity(5).length).to eq(5)
      expect(@m1.top_items_sold_by_quantity(5)[0].name).to eq(@i2.name)
      expect(@m1.top_items_sold_by_quantity(5)[0].quantity).to eq(14)
      expect(@m1.top_items_sold_by_quantity(5)[1].name).to eq(@i3.name)
      expect(@m1.top_items_sold_by_quantity(5)[1].quantity).to eq(4)
      expect(@m1.top_items_sold_by_quantity(5)[2].name).to eq(@i4.name)
      expect(@m1.top_items_sold_by_quantity(5)[2].quantity).to eq(3)
      expect(@m1.top_items_sold_by_quantity(5)[3].name).to eq(@i1.name)
      expect(@m1.top_items_sold_by_quantity(5)[3].quantity).to eq(2)
      expect(@m1.top_items_sold_by_quantity(5)[4].name).to eq(@i5.name)
      expect(@m1.top_items_sold_by_quantity(5)[4].quantity).to eq(1)
    end

    it '.total_items_sold' do
      expect(@m1.total_items_sold).to eq(24)
    end

    it '.percent_of_items_sold' do
      expect(@m1.percent_of_items_sold.round(2)).to eq(17.39)
    end

    it '.total_inventory_remaining' do
      expect(@m1.total_inventory_remaining).to eq(138)
    end

    it '.top_states_by_items_shipped' do
      expect(@m1.top_states_by_items_shipped(3)[0].state).to eq("IA")
      expect(@m1.top_states_by_items_shipped(3)[0].quantity).to eq(14)
      expect(@m1.top_states_by_items_shipped(3)[1].state).to eq("OK")
      expect(@m1.top_states_by_items_shipped(3)[1].quantity).to eq(8)
      expect(@m1.top_states_by_items_shipped(3)[2].state).to eq("CO")
      expect(@m1.top_states_by_items_shipped(3)[2].quantity).to eq(2)
    end

    it '.top_cities_by_items_shipped' do
      expect(@m1.top_cities_by_items_shipped(3)[0].city).to eq("Anywhere")
      expect(@m1.top_cities_by_items_shipped(3)[0].state).to eq("IA")
      expect(@m1.top_cities_by_items_shipped(3)[0].quantity).to eq(10)
      expect(@m1.top_cities_by_items_shipped(3)[1].city).to eq("Tulsa")
      expect(@m1.top_cities_by_items_shipped(3)[1].state).to eq("OK")
      expect(@m1.top_cities_by_items_shipped(3)[1].quantity).to eq(8)
      expect(@m1.top_cities_by_items_shipped(3)[2].city).to eq("Des Moines")
      expect(@m1.top_cities_by_items_shipped(3)[2].state).to eq("IA")
      expect(@m1.top_cities_by_items_shipped(3)[2].quantity).to eq(4)
    end

    it '.top_users_by_money_spent' do
      expect(@m1.top_users_by_money_spent(3)[0].name).to eq(@u3.name)
      expect(@m1.top_users_by_money_spent(3)[0].total.to_f).to eq(66.00)
      expect(@m1.top_users_by_money_spent(3)[1].name).to eq(@u1.name)
      expect(@m1.top_users_by_money_spent(3)[1].total.to_f).to eq(43.50)
      expect(@m1.top_users_by_money_spent(3)[2].name).to eq(@u2.name)
      expect(@m1.top_users_by_money_spent(3)[2].total.to_f).to eq(36.00)
    end

    it '.top_user_by_order_count' do
      expect(@m1.top_user_by_order_count.name).to eq(@u1.name)
      expect(@m1.top_user_by_order_count.count).to eq(3)
    end

    it '.top_user_by_item_count' do
      expect(@m1.top_user_by_item_count.name).to eq(@u3.name)
      expect(@m1.top_user_by_item_count.quantity).to eq(10)
    end
  end

  describe 'class methods' do
    it ".active_merchants" do
      active_merchants = create_list(:merchant, 3)
      inactive_merchant = create(:inactive_merchant)

      expect(User.active_merchants).to eq(active_merchants)
    end

    it '.default_users' do
      users = create_list(:user, 3)
      merchant = create(:merchant)
      admin = create(:admin)

      expect(User.default_users).to eq(users)
    end

    describe "statistics" do
      before :each do
        u1 = create(:user)
        u2 = create(:user)
        u3 = create(:user)
        u4 = create(:user)
        u5 = create(:user)
        u6 = create(:user)
        @m1, @m2, @m3, @m4, @m5, @m6, @m7 = create_list(:merchant, 7)

        @a1a = create(:address, user: u1, state: "CO", city: "Anywhere", nickname: "home")
        @a2a = create(:address, user: u2, state: "OK", city: "Tulsa", nickname: "home")
        @a3a = create(:address, user: u3, state: "IA", city: "Anywhere", nickname: "home")
        @a4a = create(:address, user: u4, state: "IA", city: "Des Moines", nickname: "home")
        @a5a = create(:address, user: u5, state: "IA", city: "Des Moines", nickname: "home")
        @a6a = create(:address, user: u6, state: "IA", city: "Des Moines", nickname: "home")




        i1 = create(:item, merchant_id: @m1.id)
        i2 = create(:item, merchant_id: @m2.id)
        i3 = create(:item, merchant_id: @m3.id)
        i4 = create(:item, merchant_id: @m4.id)
        i5 = create(:item, merchant_id: @m5.id)
        i6 = create(:item, merchant_id: @m6.id)
        i7 = create(:item, merchant_id: @m7.id)
        o1 = create(:shipped_order, user: u1)
        o2 = create(:shipped_order, user: u2)
        o3 = create(:shipped_order, user: u3)
        o4 = create(:shipped_order, user: u1)
        o5 = create(:cancelled_order, user: u5)
        o6 = create(:shipped_order, user: u6)
        o7 = create(:shipped_order, user: u6)
        oi1 = create(:fulfilled_order_item, item: i1, order: o1, created_at: 1.days.ago)
        oi2 = create(:fulfilled_order_item, item: i2, order: o2, created_at: 7.days.ago)
        oi3 = create(:fulfilled_order_item, item: i3, order: o3, created_at: 6.days.ago)
        oi4 = create(:order_item, item: i4, order: o4, created_at: 4.days.ago)
        oi5 = create(:order_item, item: i5, order: o5, created_at: 5.days.ago)
        oi6 = create(:fulfilled_order_item, item: i6, order: o6, created_at: 3.days.ago)
        oi7 = create(:fulfilled_order_item, item: i7, order: o7, created_at: 2.days.ago)
      end

      it ".merchants_sorted_by_revenue" do
        expect(User.merchants_sorted_by_revenue).to eq([@m7, @m6, @m3, @m2, @m1])
      end

      it ".top_merchants_by_revenue()" do
        expect(User.top_merchants_by_revenue(3)).to eq([@m7, @m6, @m3])
      end

      it ".merchants_sorted_by_fulfillment_time" do
        expect(User.merchants_sorted_by_fulfillment_time(1).length).to eq(1)
        expect(User.merchants_sorted_by_fulfillment_time(10).length).to eq(5)
        expect(User.merchants_sorted_by_fulfillment_time(10)).to eq([@m1, @m7, @m6, @m3, @m2])
      end

      it ".top_merchants_by_fulfillment_time" do
        expect(User.top_merchants_by_fulfillment_time(3)).to eq([@m1, @m7, @m6])
      end

      it ".bottom_merchants_by_fulfillment_time" do
        expect(User.bottom_merchants_by_fulfillment_time(3)).to eq([@m2, @m3, @m6])
      end

      it ".top_address_states_by_order_count" do
        expect(User.top_address_states_by_order_count(3)[0].state).to eq("IA")
        expect(User.top_address_states_by_order_count(3)[0].order_count).to eq(3)
        expect(User.top_address_states_by_order_count(3)[1].state).to eq("CO")
        expect(User.top_address_states_by_order_count(3)[1].order_count).to eq(2)
        expect(User.top_address_states_by_order_count(3)[2].state).to eq("OK")
        expect(User.top_address_states_by_order_count(3)[2].order_count).to eq(1)
      end

      it ".top_address_cities_by_order_count" do
        expect(User.top_address_cities_by_order_count(3)[0].state).to eq("CO")
        expect(User.top_address_cities_by_order_count(3)[0].city).to eq("Anywhere")
        expect(User.top_address_cities_by_order_count(3)[0].order_count).to eq(2)
        expect(User.top_address_cities_by_order_count(3)[1].state).to eq("IA")
        expect(User.top_address_cities_by_order_count(3)[1].city).to eq("Des Moines")
        expect(User.top_address_cities_by_order_count(3)[1].order_count).to eq(2)
        expect(User.top_address_cities_by_order_count(3)[2].state).to eq("OK")
        expect(User.top_address_cities_by_order_count(3)[2].city).to eq("Tulsa")
        expect(User.top_address_cities_by_order_count(3)[2].order_count).to eq(1)
      end
    end
  end
end

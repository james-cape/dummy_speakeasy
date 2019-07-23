require 'rails_helper'
# RSpec.describe Cart, type: :model do
RSpec.describe Cart do
  describe "Cart with existing contents" do
    before :each do
      @item_1 = create(:item, id: 1)
      @item_4 = create(:item, id: 4)
      @cart = Cart.new({"1" => 3, "4" => 2})
    end

    describe "#total_item_count" do
      it "returns the total item count" do
        expect(@cart.total_item_count).to eq(5)
      end
    end

    describe "#contents" do
      it "returns the contents" do
        expect(@cart.contents).to eq({"1" => 3, "4" => 2})
      end
    end

    describe "#count_of" do
      it "counts a particular item" do
        expect(@cart.count_of(1)).to eq(3)
      end
    end

    describe "#add_item" do
      it "increments an existing item" do
        @cart.add_item(1)
        expect(@cart.count_of(1)).to eq(4)
      end

      it "can increment an item not in the cart yet" do
        @cart.add_item(2)
        expect(@cart.count_of(2)).to eq(1)
      end
    end

    describe "#remove_item" do
      it "decrements an existing item" do
        @cart.remove_item(1)
        expect(@cart.count_of(1)).to eq(2)
      end

      it "deletes an item when count goes to zero" do
        @cart.remove_item(1)
        @cart.remove_item(1)
        @cart.remove_item(1)
        expect(@cart.contents.keys).to_not include("1")
      end
    end

    describe "#items" do
      it "can map item_ids to objects" do

        expect(@cart.items).to eq({@item_1 => 3, @item_4 => 2})
      end
    end

    describe "#total" do
      it "can calculate the total of all items in the cart" do
        expect(@cart.total).to eq(@item_1.price * 3 + @item_4.price * 2)
      end
    end

    describe "#subtotal" do
      it "calculates the total for a single item" do
        expect(@cart.subtotal(@item_1)).to eq(@cart.count_of(@item_1.id) * @item_1.price)
      end
    end
  end

  describe "Cart with empty contents" do
    before :each do
      @cart = Cart.new(nil)
    end

    describe "#total_item_count" do
      it "returns 0 when there are no contents" do
        expect(@cart.total_item_count).to eq(0)
      end
    end

    describe "#contents" do
      it "returns empty contents" do
        expect(@cart.contents).to eq({})
      end
    end

    describe "#count_of" do
      it "counts non existent items as zero" do
        expect(@cart.count_of(1)).to eq(0)
      end
    end

    describe "#add_item" do
      it "increments the item's count" do
        @cart.add_item(2)
        expect(@cart.count_of(2)).to eq(1)
      end
    end
  end

  describe "#find_discount" do
    before :each do
      @cart = Cart.new({"1" => 0, "2" => 3})

      @merchant_1 = create(:merchant)
      @merchant_2 = create(:merchant)
      @address_1 = create(:address, user: @merchant_1)
      @address_2 = create(:address, user: @merchant_2)

      @user_1 = create(:user)
      @user_2 = create(:user)
      @address_3 = create(:address, user: @user_1)
      @address_4 = create(:address, user: @user_2)

      @item_1 = create(:item, user: @merchant_1, inventory: 100, id: 1)
      @item_2 = create(:item, user: @merchant_1, inventory: 100, id: 2)
      @item_3 = create(:item, user: @merchant_2, inventory: 100, id: 3)
      @item_4 = create(:item, user: @merchant_2, inventory: 100, id: 4)

      @discount_1 = create(:discount, user: @merchant_1, minimum_quantity: 2, discount_amount: 10)
      @discount_2 = create(:discount, user: @merchant_1, minimum_quantity: 4, discount_amount: 20)
      @discount_3 = create(:discount, user: @merchant_1, minimum_quantity: 6, discount_amount: 30)

      @discount_4 = create(:discount, user: @merchant_2, minimum_quantity: 2, discount_amount: 10)
      @discount_5 = create(:discount, user: @merchant_2, minimum_quantity: 4, discount_amount: 20)
      @discount_6 = create(:discount, user: @merchant_2, minimum_quantity: 6, discount_amount: 30)

    end

    it "finds correct discount for incrementing cart items and is unaffected by other items in the cart" do
      expect(@cart.items.keys.first.find_discount(@cart)).to eq(nil)

      2.times do @cart.add_item(1) end
      expect(@cart.items.keys.first.find_discount(@cart)).to eq(@discount_1)

      2.times do @cart.add_item(1) end
      expect(@cart.items.keys.first.find_discount(@cart)).to eq(@discount_2)

      2.times do @cart.add_item(1) end
      expect(@cart.items.keys.first.find_discount(@cart)).to eq(@discount_3)

      100.times do @cart.add_item(1) end
      expect(@cart.items.keys.first.find_discount(@cart)).to eq(@discount_3)
    end
  end
end

require 'rails_helper'

include ActionView::Helpers::NumberHelper

RSpec.describe 'Profile Orders page', type: :feature do
  before :each do
    @user = create(:user)
    @admin = create(:admin)
    @address = create(:address, user: @user)
    @address_2 = create(:address, user: @user)

    @merchant_1 = create(:merchant)
    @merchant_2 = create(:merchant)

    @item_1 = create(:item, user: @merchant_1)
    @item_2 = create(:item, user: @merchant_2)

    @new_nickname = "new nickname"
    @new_street = "new street"
    @new_city = "new city"
    @new_state = "new state"
    @new_zip = "new zip code"
  end

  context 'as a registered user' do
    describe 'should show a message when user no orders' do
      scenario 'when logged in as user' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
        visit profile_orders_path

        expect(page).to have_content('You have no orders yet')
      end

      it 'allows user to delete all addresses not on orders from profile page' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit profile_path

        within "#address-details-#{@address.id}" do
          expect(page).to have_content(@address.street)
          click_button "Delete This Address"
        end

        within "#address-handler" do
          expect(page).to_not have_content(@address.street)
          expect(page).to have_content(@address_2.street)
        end

        within "#address-details-#{@address_2.id}" do
          expect(page).to have_content(@address_2.street)
          click_button "Delete This Address"
        end

        within "#address-handler" do
          expect(page).to_not have_content(@address.street)
          expect(page).to_not have_content(@address_2.street)
          expect(page).to have_content("No addresses on file")
        end

        visit item_path(@item_1)
        click_on "Add to Cart"

        expect(current_path).to eq(cart_path)

        expect(page).to_not have_button("Check Out")
        expect(page).to have_content("You have no address on file")
        expect(page).to have_button("Add New Address")

        click_button "Add New Address"

        expect(current_path).to eq(new_profile_address_path)
      end

      it 'allows user to edit addresses from profile page' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit profile_path

        within "#address-details-#{@address.id}" do
          expect(page).to have_content(@address.street)
          click_button "Edit This Address"
        end

        expect(current_path).to eq(edit_profile_address_path(@address.id))

        expect(find_field('Nickname').value).to eq(@address.nickname)
        expect(find_field('Street').value).to eq(@address.street)
        expect(find_field('City').value).to eq(@address.city)
        expect(find_field('State').value).to eq(@address.state)
        expect(find_field('Zip code').value).to eq(@address.zip_code)

        fill_in :address_nickname, with: @new_nickname
        fill_in :address_street, with: @new_street
        fill_in :address_city, with: @new_city
        fill_in :address_state, with: @new_state
        fill_in :address_zip_code, with: @new_zip

        click_button "Submit"

        @address.reload
        expect(current_path).to eq(profile_path)

        expect(@address.street).to eq(@new_street)
      end

      it 'allows user to add addresses from profile page' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit profile_path

        click_button "Add New Address"

        expect(current_path).to eq(new_profile_address_path)

        fill_in :address_nickname, with: @new_nickname
        fill_in :address_street, with: @new_street
        fill_in :address_city, with: @new_city
        fill_in :address_state, with: @new_state
        fill_in :address_zip_code, with: @new_zip

        click_button "Submit"

        expect(current_path).to eq(profile_path)

        @user.reload

        expect(@user.addresses.last.nickname).to eq("#{@new_nickname}")
      end
    end

    describe 'should show information about each order when I do have orders' do
      before :each do
        yesterday = 1.day.ago
        @order = create(:order, user: @user, created_at: yesterday, address_id: @address.id)
        @oi_1 = create(:order_item, order: @order, item: @item_1, price: 1, quantity: 1, created_at: yesterday, updated_at: yesterday)
        @oi_2 = create(:fulfilled_order_item, order: @order, item: @item_2, price: 2, quantity: 1, created_at: yesterday, updated_at: 2.hours.ago)
      end

      scenario 'when logged in as user' do
        @user.reload
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
        visit profile_orders_path
      end

      after :each do
        expect(page).to_not have_content('You have no orders yet')

        within "#order-#{@order.id}" do
          expect(page).to have_link("Order ID #{@order.id}")
          expect(page).to have_content("Created: #{@order.created_at}")
          expect(page).to have_content("Last Update: #{@order.updated_at}")
          expect(page).to have_content("Status: #{@order.status}")
          expect(page).to have_content("Item Count: #{@order.total_item_count}")
          expect(page).to have_content("Total Cost: #{@order.total_cost}")
          expect(page).to have_content("Shipping Address: #{@address.street}, #{@address.city} #{@address.state} #{@address.zip_code}")
        end
      end
    end

    describe 'should show a single order show page' do
      before :each do
        yesterday = 1.day.ago
        @order = create(:order, user: @user, created_at: yesterday, address: @address)
        @oi_1 = create(:order_item, order: @order, item: @item_1, price: 1, quantity: 3, created_at: yesterday, updated_at: yesterday)
        @oi_2 = create(:fulfilled_order_item, order: @order, item: @item_2, price: 2, quantity: 5, created_at: yesterday, updated_at: 2.hours.ago)
      end

      scenario 'when logged in as user' do
        @user.reload
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
        visit profile_order_path(@order)
      end

      it 'shows option to update shipping address' do
        @user.reload
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
        visit profile_order_path(@order)

        expect(page).to have_button("Update Shipping Address")
      end

      it 'has radio buttons to select a shipping address' do
        @user.reload

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
        visit profile_order_path(@order)

        within "#current-shipping-address" do
          expect(page).to have_content("Current Shipping Address: #{@address.street}")
          expect(@order.address).to eq(@address)
        end

        find(:css, "#radio-button-for-address-#{@address_2.id}").click
        click_button "Update Shipping Address"
        @order.reload

        within "#current-shipping-address" do
          expect(page).to have_content("Current Shipping Address: #{@address_2.street}")
          expect(@order.address).to eq(@address_2)
        end

        find(:css, "#radio-button-for-address-#{@address.id}").click
        click_button "Update Shipping Address"
        @order.reload

        within "#current-shipping-address" do
          expect(page).to have_content("Current Shipping Address: #{@address.street}")
          expect(@order.address).to eq(@address)
        end
      end

      after :each do
        expect(page).to have_content("Order ID #{@order.id}")
        expect(page).to have_content("Created: #{@order.created_at}")
        expect(page).to have_content("Last Update: #{@order.updated_at}")
        expect(page).to have_content("Status: #{@order.status}")

        within "#oitem-#{@oi_1.id}" do
          expect(page).to have_content(@oi_1.item.name)
          expect(page).to have_content(@oi_1.item.description)
          expect(page.find("#item-#{@oi_1.item.id}-image")['src']).to have_content(@oi_1.item.image)
          expect(page).to have_content("Merchant: #{@oi_1.item.user.name}")
          expect(page).to have_content("Price: #{number_to_currency(@oi_1.price)}")
          expect(page).to have_content("Quantity: #{@oi_1.quantity}")
          expect(page).to have_content("Subtotal: #{number_to_currency(@oi_1.price*@oi_1.quantity)}")
          expect(page).to have_content("Subtotal: #{number_to_currency(@oi_1.price*@oi_1.quantity)}")
          expect(page).to have_content("Fulfilled: No")
        end

        within "#oitem-#{@oi_2.id}" do
          expect(page).to have_content(@oi_2.item.name)
          expect(page).to have_content(@oi_2.item.description)
          expect(page.find("#item-#{@oi_2.item.id}-image")['src']).to have_content(@oi_2.item.image)
          expect(page).to have_content("Merchant: #{@oi_2.item.user.name}")
          expect(page).to have_content("Price: #{number_to_currency(@oi_2.price)}")
          expect(page).to have_content("Quantity: #{@oi_2.quantity}")
          expect(page).to have_content("Subtotal: #{number_to_currency(@oi_2.price*@oi_2.quantity)}")
          expect(page).to have_content("Fulfilled: Yes")
        end

        expect(page).to have_content("Item Count: #{@order.total_item_count}")
        expect(page).to have_content("Total Cost: #{number_to_currency(@order.total_cost)}")
      end
    end
  end
end

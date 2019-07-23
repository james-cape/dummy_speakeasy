require 'rails_helper'

RSpec.describe 'merchant dashboard' do
  before :each do
    @merchant = create(:merchant)
    @address_1 = create(:address, user: @merchant)

    @admin = create(:admin)
    @address_2 = create(:address, user: @admin)

    @i1, @i2 = create_list(:item, 2, user: @merchant)
    @o1, @o2 = create_list(:order, 2)
    @o3 = create(:shipped_order)
    @o4 = create(:cancelled_order)
    create(:order_item, order: @o1, item: @i1, quantity: 1, price: 2)
    create(:order_item, order: @o1, item: @i2, quantity: 2, price: 2)
    create(:order_item, order: @o2, item: @i2, quantity: 4, price: 2)
    create(:order_item, order: @o3, item: @i1, quantity: 4, price: 2)
    create(:order_item, order: @o4, item: @i2, quantity: 5, price: 2)
  end

  describe 'merchant user visits their profile' do
    describe 'shows merchant information' do
      scenario 'as a merchant' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
        visit dashboard_path
        expect(page).to_not have_button("Downgrade to User")
      end
      scenario 'as an admin' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
        visit admin_merchant_path(@merchant)
      end
      after :each do
        expect(page).to have_content(@merchant.name)
        expect(page).to have_content("Email: #{@merchant.email}")
        expect(page).to have_content("Address: #{@merchant.addresses.first.street}")
        expect(page).to have_content("City: #{@merchant.addresses.first.city}")
        expect(page).to have_content("State: #{@merchant.addresses.first.state}")
        expect(page).to have_content("Zip: #{@merchant.addresses.first.zip_code}")
      end
    end
  end

  describe 'merchant user with orders visits their profile' do
    before :each do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

      visit dashboard_path
    end
    it 'shows merchant information' do
      expect(page).to have_content(@merchant.name)
      expect(page).to have_content("Email: #{@merchant.email}")
      expect(page).to have_content("Address: #{@merchant.addresses.first.street}")
      expect(page).to have_content("City: #{@merchant.addresses.first.city}")
      expect(page).to have_content("State: #{@merchant.addresses.first.state}")
      expect(page).to have_content("Zip: #{@merchant.addresses.first.zip_code}")
    end

    it 'does not have a link to edit information' do
      expect(page).to_not have_link('Edit')
    end

    it 'shows pending order information' do
      within("#order-#{@o1.id}") do
        expect(page).to have_link(@o1.id)
        expect(page).to have_content(@o1.created_at)
        expect(page).to have_content(@o1.total_quantity_for_merchant(@merchant.id))
        expect(page).to have_content(@o1.total_price_for_merchant(@merchant.id))
      end
      within("#order-#{@o2.id}") do
        expect(page).to have_link(@o2.id)
        expect(page).to have_content(@o2.created_at)
        expect(page).to have_content(@o2.total_quantity_for_merchant(@merchant.id))
        expect(page).to have_content(@o2.total_price_for_merchant(@merchant.id))
      end
    end

    it 'does not show non-pending orders' do
      expect(page).to_not have_css("#order-#{@o3.id}")
      expect(page).to_not have_css("#order-#{@o4.id}")
    end

    describe 'shows a link to merchant items' do
      scenario 'as a merchant' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
        visit dashboard_path
        click_link('Items for Sale')
        expect(current_path).to eq(dashboard_items_path)
      end
      scenario 'as an admin' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
        visit admin_merchant_path(@merchant)
        expect(page.status_code).to eq(200)
        click_link('Items for Sale')
        expect(current_path).to eq(admin_merchant_items_path(@merchant))
      end
    end
  end
end

RSpec.describe 'merchant dashboard' do
  before :each do
    @merchant_1 = create(:merchant)
    @address_1 = create(:address, user: @merchant_1)
  end

  describe 'merchants have full CRUD on discounts from their dashboard' do
    it 'merchants can create discounts' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)

      visit dashboard_path

      new_description = "Black Friday Sale"
      new_minimum_quantity = "10"
      new_discount_amount = "50"

      click_button "Add New Bulk Discount"

      expect(current_path).to eq(new_dashboard_discount_path)

      fill_in "Description", with: new_description
      fill_in "Minimum quantity", with: new_minimum_quantity
      fill_in "Discount amount", with: new_discount_amount

      click_button "Create Discount"

      new_discount = Discount.last

      expect(current_path).to eq(dashboard_path)

      expect(page).to have_content("Your discount has been created!")

      within "#discount-#{new_discount.id}" do
        expect(page).to have_content(new_description)
        expect(page).to have_content(new_minimum_quantity)
        expect(page).to have_content(new_discount_amount)
      end
    end

    it 'merchants can have multiple discounts' do
      create(:discount, user: @merchant_1)
      create(:discount, user: @merchant_1)
      create(:discount, user: @merchant_1)

      visit login_path

      fill_in :email, with: @merchant_1.email
      fill_in :password, with: @merchant_1.password

      expect(@merchant_1.discounts.length).to eq(3)
    end

    it 'merchants can delete discounts' do
      discount_1 = create(:discount, user: @merchant_1)
      discount_2 = create(:discount, user: @merchant_1)

      visit login_path

      fill_in :email, with: @merchant_1.email
      fill_in :password, with: @merchant_1.password

      click_button "Log in"
      visit dashboard_path

      within "#discount-#{discount_1.id}" do
        click_button "Delete This Discount"
      end

      expect(current_path).to eq(dashboard_path)

      expect(page).to have_content("Your discount was deleted.")

      expect(page).to_not have_css("#discount-#{discount_1.id}")

      within "#discount-#{discount_2.id}" do
        expect(page).to have_content(discount_2.description)
        expect(page).to have_content(discount_2.minimum_quantity)
        expect(page).to have_content(discount_2.discount_amount)
      end
    end

    it 'merchants can edit discounts' do
      discount_1 = create(:discount, user: @merchant_1)

      new_description = "Black Friday Sale"
      new_minimum_quantity = "10"
      new_discount_amount = "50"

      visit login_path

      fill_in :email, with: @merchant_1.email
      fill_in :password, with: @merchant_1.password

      click_button "Log in"
      visit dashboard_path

      within "#discount-#{discount_1.id}" do
        click_button "Edit This Discount"
      end

      expect(current_path).to eq(edit_dashboard_discount_path(discount_1.id))

      fill_in "Description", with: new_description
      fill_in "Minimum quantity", with: new_minimum_quantity
      fill_in "Discount amount", with: new_discount_amount

      click_button "Submit"

      expect(current_path).to eq(dashboard_path)

      expect(page).to have_content("Your discount has been updated!")

      within "#discount-#{discount_1.id}" do
        expect(page).to have_content(new_description)
        expect(page).to have_content(new_minimum_quantity)
        expect(page).to have_content(new_discount_amount)
      end
    end
  end
end

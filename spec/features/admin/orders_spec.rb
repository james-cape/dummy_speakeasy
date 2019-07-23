require 'rails_helper'

RSpec.describe 'Admin Order workflow', type: :feature do
  before :each do
    @admin = create(:admin)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)

    user_1, user_2, user_3, user_4 = create_list(:user, 4)
    @order_1 = create(:order, user: user_1)
    @order_2 = create(:packaged_order, user: user_2)
    @order_3 = create(:shipped_order, user: user_3)
    @order_4 = create(:cancelled_order, user: user_4)
  end
  describe 'admin order index page' do
    it 'shows all orders, ship button, etc' do
      visit admin_dashboard_path

      within '#packaged-orders' do
        within "#order-#{@order_2.id}" do
          expect(page).to have_link(@order_2.user.name)
          expect(page).to have_content("Order ID #{@order_2.id}")
          expect(page).to have_content("Created: #{@order_2.created_at}")
          expect(page).to have_button('Ship Order')
        end
      end

      within '#pending-orders' do
        within "#order-#{@order_1.id}" do
          expect(page).to have_link(@order_1.user.name)
          expect(page).to have_content("Order ID #{@order_1.id}")
          expect(page).to have_content("Created: #{@order_1.created_at}")
          expect(page).to_not have_button('Ship Order')
        end
      end

      within '#shipped-orders' do
        within "#order-#{@order_3.id}" do
          expect(page).to have_link(@order_3.user.name)
          expect(page).to have_content("Order ID #{@order_3.id}")
          expect(page).to have_content("Created: #{@order_3.created_at}")
          expect(page).to_not have_button('Ship Order')
        end
      end

      within '#cancelled-orders' do
        within "#order-#{@order_4.id}" do
          expect(page).to have_link(@order_4.user.name)
          expect(page).to have_content("Order ID #{@order_4.id}")
          expect(page).to have_content("Created: #{@order_4.created_at}")
          expect(page).to_not have_button('Ship Order')
        end
      end
    end

    it 'ships an order' do
      visit admin_dashboard_path

      within '#packaged-orders' do
        within "#order-#{@order_2.id}" do
          click_button('Ship Order')
        end
      end

      expect(current_path).to eq(admin_dashboard_path)

      within '#packaged-orders' do
        expect(page).to_not have_css("#order-#{@order_2.id}")
      end

      within '#shipped-orders' do
        within "#order-#{@order_2.id}" do
          expect(page).to have_link(@order_2.user.name)
          expect(page).to have_content("Order ID #{@order_2.id}")
        end
      end
    end
  end
end
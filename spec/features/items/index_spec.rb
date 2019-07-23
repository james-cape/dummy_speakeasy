require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe 'items index workflow', type: :feature do
  describe 'shows all active items to visitors' do
    it 'displays basic item data' do
      items = create_list(:item, 3)
      out_of_stock = create(:item, inventory: 0)
      inactive_items = create_list(:inactive_item, 2)

      visit items_path

      items.each do |item|
        within "#item-#{item.id}" do
          expect(page).to have_link(item.name)
          expect(page).to have_content("Sold by: #{item.user.name}")
          expect(page).to have_content("In stock: #{item.inventory}")
          expect(page).to have_content(number_to_currency(item.price))
          expect(page.find("#item-#{item.id}-image")['src']).to have_content(item.image)
        end
      end
      within "#item-#{out_of_stock.id}" do
        expect(page).to have_content("Out of Stock")
      end
      inactive_items.each do |item|
        expect(page).to_not have_css("#item-#{item.id}")
        expect(page).to_not have_content(item.name)
      end
    end
  end

end
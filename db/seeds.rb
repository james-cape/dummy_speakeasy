require 'factory_bot_rails'

include FactoryBot::Syntax::Methods

# OrderItem.destroy_all
# Order.destroy_all
Item.destroy_all
User.destroy_all

admin = create(:admin)
user = create(:user)
merchant_1 = create(:merchant)

address_1 = create(:address, user: admin, nickname: "home")
address_2 = create(:address, user: admin, nickname: "business")
address_3 = create(:address, user: user, nickname: "home")
address_4 = create(:address, user: user, nickname: "business")
address_5 = create(:address, user: merchant_1, nickname: "home")
address_6 = create(:address, user: merchant_1, nickname: "business")


merchant_2, merchant_3, merchant_4 = create_list(:merchant, 3)
address_7 = create(:address, user: merchant_2, nickname: "home")
address_8 = create(:address, user: merchant_3, nickname: "home")
address_9 = create(:address, user: merchant_4, nickname: "home")



inactive_merchant_1 = create(:inactive_merchant)
inactive_user_1 = create(:inactive_user)

address_10 = create(:address, user: inactive_merchant_1, nickname: "home")
address_11 = create(:address, user: inactive_user_1, nickname: "home")


item_1 = create(:item, user: merchant_1)
item_2 = create(:item, user: merchant_2)
item_3 = create(:item, user: merchant_3)
item_4 = create(:item, user: merchant_4)
create_list(:item, 10, user: merchant_1)

inactive_item_1 = create(:inactive_item, user: merchant_1)
inactive_item_2 = create(:inactive_item, user: inactive_merchant_1)

# Random.new_seed
# rng = Random.new

# order = create(:completed_order, user: user)
# create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 1, created_at: (rng.rand(3)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
# create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)
# create(:fulfilled_order_item, order: order, item: item_3, price: 3, quantity: 1, created_at: (rng.rand(5)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
# create(:fulfilled_order_item, order: order, item: item_4, price: 4, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)

# # pending order
# order = create(:order, user: user)
# create(:order_item, order: order, item: item_1, price: 1, quantity: 1)
# create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).days.ago, updated_at: rng.rand(23).hours.ago)

# order = create(:cancelled_order, user: user)
# create(:order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)
# create(:order_item, order: order, item: item_3, price: 3, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)

# order = create(:completed_order, user: user)
# create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 1, created_at: (rng.rand(4)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
# create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)





puts 'seed data finished'
puts "Users created: #{User.count.to_i}"
# puts "Orders created: #{Order.count.to_i}"
puts "Items created: #{Item.count.to_i}"
# puts "OrderItems created: #{OrderItem.count.to_i}"

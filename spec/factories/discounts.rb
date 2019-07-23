FactoryBot.define do
  factory :discount, class: Discount do
    sequence(:description) { |n| "Discount description #{n}" }
    sequence(:minimum_quantity) { |n| ("#{n}".to_i+1)*2 }
    sequence(:discount_amount) { |n| ("#{n}".to_i+1)*1.5 }
  end
end

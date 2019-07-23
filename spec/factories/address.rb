FactoryBot.define do
  factory :address, class: Address do
    sequence(:street) { |n| "Address #{n}" }
    sequence(:city) { |n| "City #{n}" }
    sequence(:state) { |n| "State #{n}" }
    sequence(:zip_code) { |n| "Zip #{n}" }
  end
end

FactoryBot.define do
  factory :address do
    street_address { Faker::Address.street_address }
    secondary_address { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip { Faker::Address.zip_code }
  end
end

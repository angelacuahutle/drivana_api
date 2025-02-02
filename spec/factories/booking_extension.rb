FactoryBot.define do
    factory :booking do
      car_id { Faker::Number.number(digits: 2) }
      driver_id { Faker::Number.number(digits: 2) }
      start_date { Date.today }
      end_date { Date.today + 5 }
      status { "confirmed" }
      total_price { 50 * 5 }
    end
end
  
  
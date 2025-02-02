FactoryBot.define do
    factory :booking do
      car_id    { Faker::Number.number(digits: 2) }
      driver_id { Faker::Number.number(digits: 2) }
      start_date { Date.today }
      end_date   { start_date + 5 }
      status     { "confirmed" }
      total_price { 50.0 }
    end
  end

FactoryBot.define do
    factory :booking_extension do
      association :booking  
      start_date { Date.today }
      end_date   { Date.today + 5 }
      total_price { 50 * 5 }
    end
  end  
  
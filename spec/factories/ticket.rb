FactoryBot.define do
    factory :ticket do
      association :ticketable, factory: :booking
      issue_date { Time.current }
      daily_rate { 50 }
      rental_days { 4 }
      subtotal_rent { 0 }
      additional_charges { 10 }
      discounts { 5 }
      taxes { 15 }
      total_amount { 0 }
    end
  end

FactoryBot.define do
  factory :user do
    email { "test@example.com" }  # or use Faker if you prefer
    password { "password" }
    password_confirmation { "password" }
  end
end

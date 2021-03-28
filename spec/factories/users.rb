FactoryBot.define do
  factory :user do
    name { 'sampleboy' }
    sequence(:email) { |n| "rspec#{n}@example.com" }
    password { '12345678' }
    password_confirmation { '12345678' }
    prefecture
  end
end

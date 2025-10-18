FactoryBot.define do
  factory :comment do
    ticket { nil }
    user { nil }
    body { "MyText" }
    public { false }
  end
end

FactoryBot.define do
  factory :ticket do
    ticket_key { "MyString" }
    title { "MyString" }
    description { "MyText" }
    status { 1 }
    priority { 1 }
    category { "MyString" }
    subcategory { "MyString" }
    requester { nil }
    assignee { nil }
    first_response_at { "2025-10-18 19:46:56" }
    resolved_at { "2025-10-18 19:46:56" }
    closed_at { "2025-10-18 19:46:56" }
  end
end

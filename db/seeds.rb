# Clear existing data (for development only - be careful!)
puts "Clearing existing data..."
TicketTag.destroy_all
Comment.destroy_all
Ticket.destroy_all
Tag.destroy_all
User.destroy_all

puts "Creating users..."

# Create Admin
admin = User.create!(
  email: 'admin@supportdesk.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Admin',
  last_name: 'User',
  role: :admin
)

# Create Agents
agent1 = User.create!(
  email: 'sarah.jones@supportdesk.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Sarah',
  last_name: 'Jones',
  role: :agent
)

agent2 = User.create!(
  email: 'mike.chen@supportdesk.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Mike',
  last_name: 'Chen',
  role: :agent
)

# Create Customers
customer1 = User.create!(
  email: 'john.doe@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'John',
  last_name: 'Doe',
  role: :customer
)

customer2 = User.create!(
  email: 'jane.smith@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Jane',
  last_name: 'Smith',
  role: :customer
)

puts "Created #{User.count} users (1 admin, 2 agents, 2 customers)"

puts "Creating tags..."

# Create Tags
tag_bug = Tag.create!(name: 'bug', color: '#EF4444')           # Red
tag_feature = Tag.create!(name: 'feature', color: '#3B82F6')   # Blue
tag_question = Tag.create!(name: 'question', color: '#10B981') # Green
tag_urgent = Tag.create!(name: 'urgent', color: '#F59E0B')     # Orange
tag_billing = Tag.create!(name: 'billing', color: '#8B5CF6')   # Purple
tag_technical = Tag.create!(name: 'technical', color: '#06B6D4') # Cyan

puts "Created #{Tag.count} tags"

puts "Creating tickets..."

# Ticket 1: New ticket from customer1
ticket1 = Ticket.create!(
  title: 'Cannot login to my account',
  description: 'I have been trying to login for the past hour but keep getting an error message saying "Invalid credentials". I am sure my password is correct.',
  status: :ticket_new,
  priority: :high,
  category: 'Account',
  subcategory: 'Login Issues',
  requester: customer1
)
ticket1.tags << [tag_bug, tag_urgent]

# Ticket 2: Open ticket assigned to agent1
ticket2 = Ticket.create!(
  title: 'Feature request: Dark mode',
  description: 'It would be great to have a dark mode option in the settings. My eyes get tired when using the app at night.',
  status: :open,
  priority: :low,
  category: 'Feature Request',
  requester: customer2,
  assignee: agent1
)
ticket2.tags << tag_feature

# Ticket 3: Pending ticket with comments
ticket3 = Ticket.create!(
  title: 'Billing issue - double charged',
  description: 'I was charged twice for my subscription this month. Transaction IDs: TXN-12345 and TXN-12346. Please refund one of these charges.',
  status: :pending,
  priority: :urgent,
  category: 'Billing',
  subcategory: 'Refunds',
  requester: customer1,
  assignee: agent2,
  first_response_at: 2.hours.ago
)
ticket3.tags << [tag_billing, tag_urgent]

# Ticket 4: Resolved ticket
ticket4 = Ticket.create!(
  title: 'How do I change my email address?',
  description: 'I want to update my email address but cannot find the option in settings.',
  status: :resolved,
  priority: :medium,
  category: 'Account',
  subcategory: 'Settings',
  requester: customer2,
  assignee: agent1,
  first_response_at: 1.day.ago,
  resolved_at: 12.hours.ago
)
ticket4.tags << tag_question

# Ticket 5: Closed ticket
ticket5 = Ticket.create!(
  title: 'App crashes on startup',
  description: 'Every time I open the mobile app, it crashes immediately. I am using iPhone 12 with iOS 16.',
  status: :closed,
  priority: :high,
  category: 'Technical',
  subcategory: 'Mobile App',
  requester: customer1,
  assignee: agent2,
  first_response_at: 3.days.ago,
  resolved_at: 2.days.ago,
  closed_at: 2.days.ago
)
ticket5.tags << [tag_bug, tag_technical]

# Ticket 6-10: More diverse tickets
ticket6 = Ticket.create!(
  title: 'Export data feature not working',
  description: 'When I try to export my data as CSV, I get a 500 error.',
  status: :open,
  priority: :medium,
  category: 'Technical',
  requester: customer2,
  assignee: agent1
)
ticket6.tags << tag_bug

ticket7 = Ticket.create!(
  title: 'Question about pricing plans',
  description: 'What is the difference between the Pro and Enterprise plans?',
  status: :ticket_new,
  priority: :low,
  category: 'Sales',
  subcategory: 'Pricing',
  requester: customer1
)
ticket7.tags << [tag_question, tag_billing]

ticket8 = Ticket.create!(
  title: 'API rate limit too restrictive',
  description: 'The current API rate limit of 100 requests/hour is too low for our use case. Can we increase it?',
  status: :open,
  priority: :medium,
  category: 'Technical',
  subcategory: 'API',
  requester: customer2,
  assignee: agent2
)
ticket8.tags << [tag_technical, tag_feature]

ticket9 = Ticket.create!(
  title: 'Password reset email not received',
  description: 'I requested a password reset 30 minutes ago but have not received the email yet. I checked my spam folder.',
  status: :pending,
  priority: :high,
  category: 'Account',
  subcategory: 'Password Reset',
  requester: customer1,
  assignee: agent1,
  first_response_at: 15.minutes.ago
)
ticket9.tags << tag_bug

ticket10 = Ticket.create!(
  title: 'Add support for two-factor authentication',
  description: 'For security reasons, I would like to enable 2FA on my account. Is this feature available?',
  status: :open,
  priority: :medium,
  category: 'Security',
  requester: customer2,
  assignee: agent2
)
ticket10.tags << tag_feature

puts "Created #{Ticket.count} tickets"

puts "Creating comments..."

# Comments for ticket3 (Billing issue)
Comment.create!(
  ticket: ticket3,
  user: agent2,
  body: 'Thank you for reporting this issue. I can see the duplicate charges in our system. I have initiated a refund for transaction TXN-12346. It should appear in your account within 3-5 business days.',
  public: true
)

Comment.create!(
  ticket: ticket3,
  user: agent2,
  body: 'Internal note: Need to check why the payment gateway charged twice. Possible webhook duplication issue.',
  public: false
)

Comment.create!(
  ticket: ticket3,
  user: customer1,
  body: 'Thank you! Just wanted to confirm - will I receive an email confirmation when the refund is processed?',
  public: true
)

Comment.create!(
  ticket: ticket3,
  user: agent2,
  body: 'Yes, you will receive an email confirmation from our payment processor (Stripe) once the refund is complete.',
  public: true
)

# Comments for ticket4 (Email change - resolved)
Comment.create!(
  ticket: ticket4,
  user: agent1,
  body: 'Hi Jane, you can change your email address by going to Settings > Account > Email Address. Click the "Change" button next to your current email.',
  public: true
)

Comment.create!(
  ticket: ticket4,
  user: customer2,
  body: 'Found it! Thank you so much for the quick help.',
  public: true
)

Comment.create!(
  ticket: ticket4,
  user: agent1,
  body: 'You are welcome! Glad I could help. Marking this as resolved.',
  public: true
)

# Comments for ticket5 (App crash - closed)
Comment.create!(
  ticket: ticket5,
  user: agent2,
  body: 'Thank you for the report. This is a known issue with iOS 16 on iPhone 12. Our development team has released version 2.1.3 that fixes this crash. Please update your app from the App Store.',
  public: true
)

Comment.create!(
  ticket: ticket5,
  user: customer1,
  body: 'Updated the app and it works perfectly now! Thanks!',
  public: true
)

Comment.create!(
  ticket: ticket5,
  user: agent2,
  body: 'Excellent! Closing this ticket. Feel free to reach out if you have any other issues.',
  public: true
)

# Comments for ticket6 (Export data)
Comment.create!(
  ticket: ticket6,
  user: agent1,
  body: 'Looking into this issue. Could you please let me know approximately how many records you are trying to export?',
  public: true
)

# Comments for ticket9 (Password reset)
Comment.create!(
  ticket: ticket9,
  user: agent1,
  body: 'I can see that the password reset email was sent to john.doe@example.com. Sometimes email providers delay delivery. I have manually sent another reset link to your email. Please check again in the next few minutes.',
  public: true
)

puts "Created #{Comment.count} comments (mix of public and internal)"

puts "\n================================"
puts "Seed data created successfully!"
puts "================================"
puts "\nTest credentials:"
puts "  Admin:     admin@supportdesk.com / password123"
puts "  Agent 1:   sarah.jones@supportdesk.com / password123"
puts "  Agent 2:   mike.chen@supportdesk.com / password123"
puts "  Customer 1: john.doe@example.com / password123"
puts "  Customer 2: jane.smith@example.com / password123"
puts "\nSummary:"
puts "  Users: #{User.count}"
puts "  Tickets: #{Ticket.count}"
puts "  Comments: #{Comment.count}"
puts "  Tags: #{Tag.count}"
puts "\nTicket statuses:"
puts "  New: #{Ticket.ticket_new.count}"
puts "  Open: #{Ticket.open.count}"
puts "  Pending: #{Ticket.pending.count}"
puts "  Resolved: #{Ticket.resolved.count}"
puts "  Closed: #{Ticket.closed.count}"

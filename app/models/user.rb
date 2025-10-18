class User < ApplicationRecord
  # Use bcrypt to securely hash passwords
  has_secure_password

  # Define role enum: admin=0, agent=1, customer=2
  enum role: { admin: 0, agent: 1, customer: 2 }

  # Associations
  has_many :created_tickets, class_name: 'Ticket', foreign_key: 'requester_id', dependent: :restrict_with_error
  has_many :assigned_tickets, class_name: 'Ticket', foreign_key: 'assignee_id', dependent: :nullify
  has_many :comments, dependent: :restrict_with_error

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: :password_required?
  validates :role, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  # Normalize email to lowercase before saving
  before_save :normalize_email

  # Full name helper method
  def full_name
    "#{first_name} #{last_name}".strip
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def password_required?
    password_digest.nil? || password.present?
  end
end

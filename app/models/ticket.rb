class Ticket < ApplicationRecord
  # Associations
  belongs_to :requester, class_name: 'User'
  belongs_to :assignee, class_name: 'User', optional: true
  has_many :comments, dependent: :destroy
  has_many :ticket_tags, dependent: :destroy
  has_many :tags, through: :ticket_tags

  # Enums
  enum :status, { ticket_new: 0, open: 1, pending: 2, resolved: 3, closed: 4 }
  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }

  # Validations
  validates :ticket_key, presence: true, uniqueness: true
  validates :title, presence: true, length: { minimum: 3, maximum: 255 }
  validates :description, length: { maximum: 10000 }, allow_blank: true
  validates :status, presence: true
  validates :priority, presence: true

  # Callbacks
  before_validation :generate_ticket_key, on: :create

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_priority, ->(priority) { where(priority: priority) if priority.present? }
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :assigned_to, ->(user_id) { where(assignee_id: user_id) if user_id.present? }
  scope :created_by, ->(user_id) { where(requester_id: user_id) if user_id.present? }

  # Instance methods
  def assign_to(user)
    update(assignee: user, status: :open) if ticket_new?
  end

  def mark_first_response
    update(first_response_at: Time.current) if first_response_at.nil?
  end

  def resolve
    update(status: :resolved, resolved_at: Time.current)
  end

  def close
    resolve if !resolved? && !closed?
    update(status: :closed, closed_at: Time.current)
  end

  private

  def generate_ticket_key
    return if ticket_key.present?

    # Generate ticket key like SUP-000001, SUP-000002, etc.
    last_ticket = Ticket.order(id: :desc).first
    next_number = last_ticket ? last_ticket.id + 1 : 1
    self.ticket_key = "SUP-#{next_number.to_s.rjust(6, '0')}"
  end
end

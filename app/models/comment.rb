class Comment < ApplicationRecord
  # Associations
  belongs_to :ticket
  belongs_to :user

  # Validations
  validates :body, presence: true, length: { minimum: 1, maximum: 10000 }
  validates :public, inclusion: { in: [true, false] }

  # Callbacks
  after_create :mark_ticket_first_response

  # Scopes
  scope :public_comments, -> { where(public: true) }
  scope :internal_notes, -> { where(public: false) }
  scope :chronological, -> { order(created_at: :asc) }

  # Instance methods
  def author_name
    user.full_name
  end

  def internal?
    !public
  end

  private

  def mark_ticket_first_response
    # Mark first response time when an agent/admin first responds
    if user.agent? || user.admin?
      ticket.mark_first_response
    end
  end
end

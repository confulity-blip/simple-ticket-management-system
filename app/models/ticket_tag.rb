class TicketTag < ApplicationRecord
  # Associations
  belongs_to :ticket
  belongs_to :tag

  # Validations
  validates :ticket_id, uniqueness: { scope: :tag_id, message: 'already has this tag' }
end

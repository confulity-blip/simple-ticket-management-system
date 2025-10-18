class Tag < ApplicationRecord
  # Associations
  has_many :ticket_tags, dependent: :destroy
  has_many :tickets, through: :ticket_tags

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false },
            length: { minimum: 2, maximum: 50 }
  validates :color, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: 'must be a valid hex color' },
            allow_blank: true

  # Callbacks
  before_save :normalize_name

  # Scopes
  scope :alphabetical, -> { order(name: :asc) }

  private

  def normalize_name
    self.name = name.downcase.strip if name.present?
  end
end

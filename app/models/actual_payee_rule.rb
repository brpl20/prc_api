# frozen_string_literal: true

# Modelo para regras de beneficiários do Actual Budget
class ActualPayeeRule < ApplicationRecord
  belongs_to :actual_payee
  belongs_to :team, optional: true

  validates :actual_id, presence: true, uniqueness: { scope: :team_id }
  validates :rule_type, presence: true
  validates :value, presence: true

  scope :active, -> { where(tombstone: false) }
  scope :by_type, ->(type) { where(rule_type: type) }

  def matches?(text)
    return false if text.blank?
    
    case rule_type
    when 'equals'
      text.downcase == value.downcase
    when 'contains'
      text.downcase.include?(value.downcase)
    when 'starts_with'
      text.downcase.start_with?(value.downcase)
    when 'ends_with'
      text.downcase.end_with?(value.downcase)
    else
      false
    end
  end
end
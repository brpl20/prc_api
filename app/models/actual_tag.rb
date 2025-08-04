# frozen_string_literal: true

# Modelo para tags do Actual Budget
class ActualTag < ApplicationRecord
  belongs_to :team, optional: true
  has_many :actual_transaction_tags, dependent: :destroy
  has_many :actual_transactions, through: :actual_transaction_tags

  validates :actual_id, presence: true, uniqueness: { scope: :team_id }
  validates :tag, presence: true, uniqueness: { scope: :team_id }
  validates :color, format: { with: /\A#[0-9A-F]{6}\z/i }, allow_blank: true

  scope :active, -> { where(tombstone: false) }
  scope :by_name, -> { order(:tag) }

  def transaction_count
    actual_transactions.count
  end

  def total_amount
    actual_transactions.sum(:amount)
  end
end
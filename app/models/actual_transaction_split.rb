# frozen_string_literal: true

# Modelo para splits de transação do Actual Budget
class ActualTransactionSplit < ApplicationRecord
  belongs_to :actual_transaction
  belongs_to :actual_category, optional: true
  belongs_to :team, optional: true

  validates :amount, presence: true

  scope :for_category, ->(category_id) { where(actual_category_id: category_id) }

  def amount_in_cents
    amount || 0
  end
end
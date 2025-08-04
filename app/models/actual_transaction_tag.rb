# frozen_string_literal: true

# Modelo para relacionamento entre transações e tags do Actual Budget
class ActualTransactionTag < ApplicationRecord
  belongs_to :actual_transaction
  belongs_to :actual_tag

  validates :actual_transaction_id, uniqueness: { scope: :actual_tag_id }
end
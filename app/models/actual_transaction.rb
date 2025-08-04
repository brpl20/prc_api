# frozen_string_literal: true

# Modelo para integração com transações do Actual Budget
class ActualTransaction < ApplicationRecord
  belongs_to :actual_account
  belongs_to :actual_category, optional: true
  belongs_to :actual_payee, optional: true
  belongs_to :transaction, optional: true
  belongs_to :team, optional: true
  has_many :actual_transaction_splits, dependent: :destroy

  validates :actual_id, presence: true, uniqueness: { scope: :team_id }
  validates :amount, presence: true
  validates :date, presence: true

  scope :cleared, -> { where(cleared: true) }
  scope :reconciled, -> { where(reconciled: true) }
  scope :pending, -> { where(cleared: false, reconciled: false) }
  scope :transfers, -> { where.not(transfer_id: nil) }
  scope :by_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }

  # Parent/child relationship for split transactions
  belongs_to :parent_transaction, class_name: 'ActualTransaction', 
             foreign_key: 'parent_id', optional: true
  has_many :child_transactions, class_name: 'ActualTransaction', 
           foreign_key: 'parent_id', dependent: :destroy

  def split_transaction?
    is_parent || parent_id.present?
  end

  def amount_in_cents
    amount || 0
  end

  def formatted_date
    Date.parse(date.to_s) if date
  end

  def transfer?
    transfer_id.present?
  end

  def imported?
    imported_id.present?
  end
end
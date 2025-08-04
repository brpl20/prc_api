# frozen_string_literal: true

# Modelo para integração com contas do Actual Budget
class ActualAccount < ApplicationRecord
  belongs_to :account, optional: true
  belongs_to :team, optional: true
  has_many :actual_transactions, dependent: :destroy
  has_many :actual_bank_syncs, dependent: :destroy

  validates :actual_id, presence: true, uniqueness: { scope: :team_id }
  validates :name, presence: true
  validates :offbudget, inclusion: { in: [true, false] }
  validates :closed, inclusion: { in: [true, false] }

  scope :active, -> { where(closed: false, tombstone: false) }
  scope :on_budget, -> { where(offbudget: false) }
  scope :off_budget, -> { where(offbudget: true) }
  scope :synced, -> { where.not(account_id: nil) }

  enum sync_source: {
    manual: 0,
    simple_fin: 1,
    go_cardless: 2,
    pluggy_ai: 3
  }, _prefix: true

  def sync_enabled?
    account_id.present? && sync_source.present?
  end

  def last_sync_date
    last_sync&.to_date
  end

  def balance_in_cents
    balance_current || 0
  end

  def available_balance_in_cents
    balance_available || balance_current || 0
  end
end
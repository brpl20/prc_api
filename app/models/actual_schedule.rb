# frozen_string_literal: true

# Modelo para integração com transações agendadas do Actual Budget
class ActualSchedule < ApplicationRecord
  belongs_to :team, optional: true
  has_many :actual_transactions

  validates :actual_id, presence: true, uniqueness: { scope: :team_id }
  validates :rule_data, presence: true
  validates :active, inclusion: { in: [true, false] }
  validates :completed, inclusion: { in: [true, false] }
  validates :posts_transaction, inclusion: { in: [true, false] }

  scope :active, -> { where(active: true, tombstone: false) }
  scope :inactive, -> { where(active: false) }
  scope :completed, -> { where(completed: true) }
  scope :pending, -> { where(completed: false) }
  scope :auto_posting, -> { where(posts_transaction: true) }

  def rule
    JSON.parse(rule_data) rescue {}
  end

  def frequency
    rule['frequency']
  end

  def amount
    rule['amount']
  end

  def payee_name
    rule['payee']
  end

  def next_date
    next_date_record&.local_next_date
  end

  def overdue?
    next_date && next_date < Date.today
  end
end
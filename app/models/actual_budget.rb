# frozen_string_literal: true

# Modelo para integração com orçamentos mensais do Actual Budget
class ActualBudget < ApplicationRecord
  belongs_to :team, optional: true
  belongs_to :actual_category
  
  validates :month, presence: true
  validates :actual_category_id, uniqueness: { scope: [:month, :team_id] }
  
  scope :for_month, ->(month) { where(month: month) }
  scope :for_year, ->(year) { where('month LIKE ?', "#{year}-%") }
  scope :active, -> { joins(:actual_category).where(actual_categories: { tombstone: false }) }

  def amount_in_cents
    amount || 0
  end

  def carryover_in_cents
    carryover || 0
  end

  def goal_in_cents
    goal || 0
  end

  def month_date
    Date.parse("#{month}-01") if month
  end

  def overspent?
    spent && budgeted && spent > budgeted
  end

  def percentage_spent
    return 0 if budgeted.nil? || budgeted.zero?
    ((spent || 0).to_f / budgeted * 100).round(2)
  end
end
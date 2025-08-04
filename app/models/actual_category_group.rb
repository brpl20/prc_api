# frozen_string_literal: true

# Modelo para integração com grupos de categorias do Actual Budget
class ActualCategoryGroup < ApplicationRecord
  belongs_to :team, optional: true
  has_many :actual_categories, dependent: :destroy

  validates :actual_id, presence: true, uniqueness: { scope: :team_id }
  validates :name, presence: true
  validates :is_income, inclusion: { in: [true, false] }

  scope :active, -> { where(tombstone: false) }
  scope :income, -> { where(is_income: true) }
  scope :expense, -> { where(is_income: false) }
  scope :with_categories, -> { includes(:actual_categories) }

  def total_budgeted
    actual_categories.sum(:budgeted_amount)
  end

  def total_spent
    actual_categories.joins(:actual_transactions)
                     .sum('actual_transactions.amount')
  end
end
# frozen_string_literal: true

# Modelo para integração com categorias do Actual Budget
class ActualCategory < ApplicationRecord
  belongs_to :actual_category_group
  belongs_to :category, optional: true
  belongs_to :team, optional: true
  has_many :actual_transactions, dependent: :nullify

  validates :actual_id, presence: true, uniqueness: { scope: :team_id }
  validates :name, presence: true
  validates :is_income, inclusion: { in: [true, false] }
  validates :hidden, inclusion: { in: [true, false] }

  scope :active, -> { where(tombstone: false, hidden: false) }
  scope :income, -> { where(is_income: true) }
  scope :expense, -> { where(is_income: false) }
  scope :visible, -> { where(hidden: false) }

  def goal_amount
    goal_def&.dig('amount')
  end

  def goal_type
    goal_def&.dig('type')
  end

  def has_goal?
    goal_def.present?
  end
end
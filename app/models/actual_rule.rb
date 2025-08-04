# frozen_string_literal: true

# Modelo para integração com regras do Actual Budget
class ActualRule < ApplicationRecord
  belongs_to :team, optional: true

  validates :actual_id, presence: true, uniqueness: { scope: :team_id }
  validates :stage, presence: true
  validates :conditions_data, presence: true
  validates :actions_data, presence: true

  scope :active, -> { where(tombstone: false) }
  scope :pre_stage, -> { where(stage: 'pre') }
  scope :post_stage, -> { where(stage: 'post') }

  def conditions
    JSON.parse(conditions_data) rescue []
  end

  def actions
    JSON.parse(actions_data) rescue []
  end

  def applies_to_transaction?(transaction)
    conditions.all? do |condition|
      evaluate_condition(condition, transaction)
    end
  end

  private

  def evaluate_condition(condition, transaction)
    field = condition['field']
    op = condition['op']
    value = condition['value']

    case field
    when 'payee'
      evaluate_string_condition(transaction.payee&.name, op, value)
    when 'amount'
      evaluate_numeric_condition(transaction.amount, op, value)
    when 'category'
      evaluate_string_condition(transaction.category&.name, op, value)
    else
      false
    end
  end

  def evaluate_string_condition(field_value, op, value)
    return false if field_value.nil?
    
    case op
    when 'contains'
      field_value.downcase.include?(value.downcase)
    when 'equals'
      field_value.downcase == value.downcase
    else
      false
    end
  end

  def evaluate_numeric_condition(field_value, op, value)
    return false if field_value.nil?
    
    case op
    when 'gt'
      field_value > value.to_i
    when 'lt'
      field_value < value.to_i
    when 'equals'
      field_value == value.to_i
    else
      false
    end
  end
end
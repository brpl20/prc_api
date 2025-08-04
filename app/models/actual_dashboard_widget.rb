# frozen_string_literal: true

# Modelo para integração com widgets do dashboard do Actual Budget
class ActualDashboardWidget < ApplicationRecord
  belongs_to :team, optional: true
  belongs_to :admin, optional: true

  validates :actual_id, presence: true, uniqueness: { scope: :team_id }
  validates :widget_type, presence: true
  validates :width, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 12 }
  validates :height, presence: true, numericality: { greater_than: 0 }
  validates :x, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :y, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(tombstone: false) }
  scope :by_position, -> { order(:y, :x) }
  scope :for_dashboard, ->(team_id) { where(team_id: team_id).active.by_position }

  enum widget_type: {
    net_worth_card: 'net-worth-card',
    cash_flow_card: 'cash-flow-card',
    spending_card: 'spending-card',
    custom_report: 'custom-report',
    budget_summary: 'budget-summary',
    account_balance: 'account-balance'
  }

  def metadata
    meta_data ? JSON.parse(meta_data) : {}
  end

  def update_metadata(data)
    self.meta_data = data.to_json
  end

  def position
    { x: x, y: y, width: width, height: height }
  end
end
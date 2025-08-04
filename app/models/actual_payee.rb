# frozen_string_literal: true

# Modelo para integração com beneficiários do Actual Budget
class ActualPayee < ApplicationRecord
  belongs_to :payee, optional: true
  belongs_to :team, optional: true
  belongs_to :default_category, class_name: 'ActualCategory', 
             foreign_key: 'category_id', optional: true
  belongs_to :transfer_account, class_name: 'ActualAccount', 
             foreign_key: 'transfer_acct', optional: true
  has_many :actual_transactions, dependent: :nullify
  has_many :actual_payee_rules, dependent: :destroy

  validates :actual_id, presence: true, uniqueness: { scope: :team_id }
  validates :name, presence: true
  validates :favorite, inclusion: { in: [true, false] }

  scope :active, -> { where(tombstone: false) }
  scope :favorites, -> { where(favorite: true) }
  scope :with_rules, -> { includes(:actual_payee_rules) }
  scope :transfers, -> { where.not(transfer_acct: nil) }

  def transfer_payee?
    transfer_acct.present?
  end

  def has_rules?
    actual_payee_rules.any?
  end
end
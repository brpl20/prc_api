# frozen_string_literal: true

# Modelo para integração com sincronização bancária do Actual Budget
class ActualBankSync < ApplicationRecord
  belongs_to :actual_account
  belongs_to :team, optional: true

  validates :sync_source, presence: true
  validates :bank_id, presence: true
  validates :account_id, presence: true

  scope :active, -> { where(active: true) }
  scope :by_source, ->(source) { where(sync_source: source) }
  scope :recent, -> { order(last_sync_at: :desc) }

  enum sync_source: {
    simple_fin: 'simpleFin',
    go_cardless: 'goCardless',
    pluggy_ai: 'pluggyai'
  }

  enum status: {
    pending: 0,
    syncing: 1,
    success: 2,
    failed: 3
  }

  def sync_needed?
    last_sync_at.nil? || last_sync_at < 4.hours.ago
  end

  def sync_credentials
    encrypted_credentials ? JSON.parse(decrypt(encrypted_credentials)) : {}
  end

  def store_credentials(credentials)
    self.encrypted_credentials = encrypt(credentials.to_json)
  end

  private

  def encrypt(data)
    # Implementar criptografia apropriada
    Base64.encode64(data)
  end

  def decrypt(data)
    # Implementar descriptografia apropriada
    Base64.decode64(data)
  end
end
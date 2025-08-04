# frozen_string_literal: true

# Serviço para sincronizar dados com Actual Budget
class ActualSyncService
  attr_reader :team, :actual_db_path, :errors

  def initialize(team, actual_db_path)
    @team = team
    @actual_db_path = actual_db_path
    @errors = []
  end

  def sync_all
    ActiveRecord::Base.transaction do
      sync_accounts
      sync_category_groups
      sync_categories
      sync_payees
      sync_transactions
      sync_budgets
      sync_schedules
      sync_rules
      sync_tags
    end
    
    { success: errors.empty?, errors: errors }
  rescue StandardError => e
    errors << "Sync failed: #{e.message}"
    { success: false, errors: errors }
  end

  private

  def sync_accounts
    # Importar contas do Actual
    # Esta é uma implementação exemplo - você precisará adaptar
    # para ler do banco SQLite do Actual
  end

  def sync_category_groups
    # Importar grupos de categorias
  end

  def sync_categories
    # Importar categorias
  end

  def sync_payees
    # Importar beneficiários
  end

  def sync_transactions
    # Importar transações
  end

  def sync_budgets
    # Importar orçamentos
  end

  def sync_schedules
    # Importar agendamentos
  end

  def sync_rules
    # Importar regras
  end

  def sync_tags
    # Importar tags
  end
end
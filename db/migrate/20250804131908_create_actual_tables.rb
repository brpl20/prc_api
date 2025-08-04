# frozen_string_literal: true

class CreateActualTables < ActiveRecord::Migration[7.0]
  def change
    # Tabela de contas do Actual
    create_table :actual_accounts do |t|
      t.string :actual_id, null: false
      t.references :account, null: true, foreign_key: true
      t.references :team, null: true, foreign_key: true
      t.string :name, null: false
      t.boolean :offbudget, default: false, null: false
      t.boolean :closed, default: false, null: false
      t.integer :sort_order
      t.string :account_id # ID da conta no provedor de sync
      t.string :bank_name
      t.integer :bank_id
      t.string :mask
      t.string :official_name
      t.integer :balance_current
      t.integer :balance_available
      t.integer :balance_limit
      t.integer :sync_source
      t.datetime :last_sync
      t.datetime :last_reconciled
      t.boolean :tombstone, default: false, null: false
      t.timestamps

      t.index [:actual_id, :team_id], unique: true
      t.index :team_id
      t.index :account_id
      t.index :tombstone
    end

    # Tabela de grupos de categorias
    create_table :actual_category_groups do |t|
      t.string :actual_id, null: false
      t.references :team, null: true, foreign_key: true
      t.string :name, null: false
      t.boolean :is_income, default: false, null: false
      t.integer :sort_order
      t.boolean :tombstone, default: false, null: false
      t.timestamps

      t.index [:actual_id, :team_id], unique: true
      t.index :team_id
      t.index :is_income
      t.index :tombstone
    end

    # Tabela de categorias
    create_table :actual_categories do |t|
      t.string :actual_id, null: false
      t.references :actual_category_group, null: false, foreign_key: true
      t.references :category, null: true, foreign_key: true
      t.references :team, null: true, foreign_key: true
      t.string :name, null: false
      t.boolean :is_income, default: false, null: false
      t.boolean :hidden, default: false, null: false
      t.json :goal_def
      t.integer :sort_order
      t.boolean :tombstone, default: false, null: false
      t.timestamps

      t.index [:actual_id, :team_id], unique: true
      t.index :team_id
      t.index :actual_category_group_id
      t.index :is_income
      t.index :hidden
      t.index :tombstone
    end

    # Tabela de beneficiários
    create_table :actual_payees do |t|
      t.string :actual_id, null: false
      t.references :payee, null: true, foreign_key: true
      t.references :team, null: true, foreign_key: true
      t.string :name, null: false
      t.references :category, null: true, foreign_key: { to_table: :actual_categories }
      t.string :transfer_acct
      t.boolean :favorite, default: false, null: false
      t.boolean :tombstone, default: false, null: false
      t.timestamps

      t.index [:actual_id, :team_id], unique: true
      t.index :team_id
      t.index :transfer_acct
      t.index :favorite
      t.index :tombstone
    end

    # Tabela de transações
    create_table :actual_transactions do |t|
      t.string :actual_id, null: false
      t.references :actual_account, null: false, foreign_key: true
      t.references :actual_category, null: true, foreign_key: true
      t.references :actual_payee, null: true, foreign_key: true
      t.references :transaction, null: true, foreign_key: true
      t.references :team, null: true, foreign_key: true
      t.boolean :is_parent, default: false
      t.boolean :is_child, default: false
      t.string :parent_id
      t.integer :amount, null: false
      t.string :notes
      t.integer :date, null: false
      t.string :imported_id
      t.string :imported_payee
      t.boolean :starting_balance_flag, default: false
      t.string :transfer_id
      t.decimal :sort_order
      t.boolean :cleared, default: false
      t.boolean :reconciled, default: false
      t.string :error
      t.string :location
      t.string :financial_id
      t.string :type
      t.boolean :tombstone, default: false, null: false
      t.timestamps

      t.index [:actual_id, :team_id], unique: true
      t.index :team_id
      t.index :actual_account_id
      t.index :actual_category_id
      t.index :actual_payee_id
      t.index :date
      t.index :parent_id
      t.index :transfer_id
      t.index :cleared
      t.index :reconciled
      t.index :tombstone
    end

    # Tabela de orçamentos
    create_table :actual_budgets do |t|
      t.string :month, null: false
      t.references :actual_category, null: false, foreign_key: true
      t.references :team, null: true, foreign_key: true
      t.integer :amount
      t.integer :carryover
      t.integer :goal
      t.integer :budgeted
      t.integer :spent
      t.boolean :tombstone, default: false, null: false
      t.timestamps

      t.index [:month, :actual_category_id, :team_id], unique: true
      t.index :team_id
      t.index :month
      t.index :actual_category_id
      t.index :tombstone
    end

    # Tabela de regras
    create_table :actual_rules do |t|
      t.string :actual_id, null: false
      t.references :team, null: true, foreign_key: true
      t.string :stage, null: false
      t.text :conditions_data, null: false
      t.text :actions_data, null: false
      t.boolean :tombstone, default: false, null: false
      t.timestamps

      t.index [:actual_id, :team_id], unique: true
      t.index :team_id
      t.index :stage
      t.index :tombstone
    end

    # Tabela de agendamentos
    create_table :actual_schedules do |t|
      t.string :actual_id, null: false
      t.references :team, null: true, foreign_key: true
      t.string :name
      t.text :rule_data, null: false
      t.boolean :active, default: false, null: false
      t.boolean :completed, default: false, null: false
      t.boolean :posts_transaction, default: false, null: false
      t.boolean :tombstone, default: false, null: false
      t.timestamps

      t.index [:actual_id, :team_id], unique: true
      t.index :team_id
      t.index :active
      t.index :completed
      t.index :tombstone
    end

    # Tabela de sincronização bancária
    create_table :actual_bank_syncs do |t|
      t.references :actual_account, null: false, foreign_key: true
      t.references :team, null: true, foreign_key: true
      t.string :sync_source, null: false
      t.string :bank_id, null: false
      t.string :account_id, null: false
      t.text :encrypted_credentials
      t.boolean :active, default: true, null: false
      t.integer :status, default: 0
      t.datetime :last_sync_at
      t.string :last_error
      t.timestamps

      t.index :team_id
      t.index :sync_source
      t.index :active
      t.index :status
    end

    # Tabela de widgets do dashboard
    create_table :actual_dashboard_widgets do |t|
      t.string :actual_id, null: false
      t.references :team, null: true, foreign_key: true
      t.references :admin, null: true, foreign_key: true
      t.string :widget_type, null: false
      t.integer :width, null: false
      t.integer :height, null: false
      t.integer :x, null: false
      t.integer :y, null: false
      t.text :meta_data
      t.boolean :tombstone, default: false, null: false
      t.timestamps

      t.index [:actual_id, :team_id], unique: true
      t.index :team_id
      t.index :admin_id
      t.index :widget_type
      t.index :tombstone
    end

    # Tabela de regras de beneficiários
    create_table :actual_payee_rules do |t|
      t.string :actual_id, null: false
      t.references :actual_payee, null: false, foreign_key: true
      t.references :team, null: true, foreign_key: true
      t.string :rule_type, null: false
      t.string :value, null: false
      t.boolean :tombstone, default: false, null: false
      t.timestamps

      t.index [:actual_id, :team_id], unique: true
      t.index :team_id
      t.index :actual_payee_id
      t.index [:rule_type, :value]
      t.index :tombstone
    end

    # Tabela de splits de transação
    create_table :actual_transaction_splits do |t|
      t.references :actual_transaction, null: false, foreign_key: true
      t.references :actual_category, null: true, foreign_key: true
      t.references :team, null: true, foreign_key: true
      t.integer :amount, null: false
      t.string :notes
      t.timestamps

      t.index :team_id
      t.index :actual_transaction_id
      t.index :actual_category_id
    end

    # Tabela para próximas datas de agendamento
    create_table :actual_schedule_next_dates do |t|
      t.references :actual_schedule, null: false, foreign_key: true
      t.integer :local_next_date
      t.integer :local_next_date_ts
      t.integer :base_next_date
      t.integer :base_next_date_ts
      t.timestamps

      t.index :actual_schedule_id, unique: true
    end

    # Tabela de tags (nova funcionalidade do Actual)
    create_table :actual_tags do |t|
      t.string :actual_id, null: false
      t.references :team, null: true, foreign_key: true
      t.string :tag, null: false
      t.string :color
      t.text :description
      t.boolean :tombstone, default: false, null: false
      t.timestamps

      t.index [:actual_id, :team_id], unique: true
      t.index :team_id
      t.index :tag
      t.index :tombstone
    end

    # Tabela de relacionamento entre transações e tags
    create_table :actual_transaction_tags do |t|
      t.references :actual_transaction, null: false, foreign_key: true
      t.references :actual_tag, null: false, foreign_key: true
      t.timestamps

      t.index [:actual_transaction_id, :actual_tag_id], unique: true
    end
  end
end

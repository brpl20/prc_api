# Integração com Actual Budget

Este documento descreve a integração do sistema PRC API com o Actual Budget, uma plataforma de gestão financeira pessoal.

## Visão Geral

A integração permite que os usuários do sistema jurídico importem e sincronizem dados financeiros do Actual Budget, facilitando o controle financeiro dos escritórios de advocacia e a gestão de honorários.

## Estrutura de Dados

### Modelos Principais

1. **ActualAccount** - Contas bancárias e cartões
   - Sincronização com bancos via SimpleFin, GoCardless ou PluggyAI
   - Suporte para contas on-budget e off-budget
   - Rastreamento de saldo e reconciliação

2. **ActualTransaction** - Transações financeiras
   - Suporte para transações divididas (splits)
   - Transferências entre contas
   - Status de cleared/reconciled
   - Tags personalizadas

3. **ActualCategory** - Categorias de despesas/receitas
   - Agrupadas em ActualCategoryGroup
   - Suporte para metas de orçamento
   - Categorias ocultas

4. **ActualPayee** - Beneficiários
   - Regras automáticas de categorização
   - Favoritos
   - Transferências internas

5. **ActualBudget** - Orçamentos mensais
   - Valores orçados por categoria
   - Acompanhamento de gastos
   - Metas e carryover

6. **ActualSchedule** - Transações agendadas
   - Recorrências
   - Auto-posting
   - Próximas datas

7. **ActualRule** - Regras de automação
   - Condições e ações
   - Estágios pre/post

8. **ActualTag** - Etiquetas personalizadas
   - Cores customizáveis
   - Relacionamento N:N com transações

## Tabelas do Banco de Dados

A migration `CreateActualTables` cria as seguintes tabelas:

- `actual_accounts` - Contas financeiras
- `actual_category_groups` - Grupos de categorias
- `actual_categories` - Categorias
- `actual_payees` - Beneficiários
- `actual_transactions` - Transações
- `actual_budgets` - Orçamentos mensais
- `actual_rules` - Regras de automação
- `actual_schedules` - Agendamentos
- `actual_bank_syncs` - Sincronizações bancárias
- `actual_dashboard_widgets` - Widgets do dashboard
- `actual_payee_rules` - Regras de beneficiários
- `actual_transaction_splits` - Divisões de transação
- `actual_schedule_next_dates` - Próximas datas de agendamento
- `actual_tags` - Tags
- `actual_transaction_tags` - Relacionamento transação-tag

## Funcionalidades

### 1. Importação de Dados
- Importar arquivo de backup do Actual (.zip)
- Sincronizar dados incrementalmente
- Mapeamento automático com entidades existentes

### 2. Sincronização Bancária
- Suporte para múltiplos provedores
- Atualização automática de saldos
- Importação de transações

### 3. Gestão de Orçamento
- Orçamentos por categoria
- Acompanhamento de metas
- Relatórios de desempenho

### 4. Dashboard Personalizado
- Widgets configuráveis
- Métricas financeiras
- Gráficos e visualizações

## API Endpoints

### Contas
- `GET /api/v1/actual_accounts` - Listar contas
- `POST /api/v1/actual_accounts` - Criar conta
- `GET /api/v1/actual_accounts/:id` - Detalhes da conta
- `PUT /api/v1/actual_accounts/:id` - Atualizar conta
- `DELETE /api/v1/actual_accounts/:id` - Excluir conta
- `POST /api/v1/actual_accounts/:id/sync` - Sincronizar conta
- `GET /api/v1/actual_accounts/:id/balance_history` - Histórico de saldo

### Transações
- `GET /api/v1/actual_transactions` - Listar transações
- `POST /api/v1/actual_transactions` - Criar transação
- `GET /api/v1/actual_transactions/:id` - Detalhes da transação
- `PUT /api/v1/actual_transactions/:id` - Atualizar transação
- `DELETE /api/v1/actual_transactions/:id` - Excluir transação

### Categorias
- `GET /api/v1/actual_categories` - Listar categorias
- `POST /api/v1/actual_categories` - Criar categoria
- `GET /api/v1/actual_categories/:id/budget` - Orçamento da categoria

### Orçamentos
- `GET /api/v1/actual_budgets/:month` - Orçamento do mês
- `PUT /api/v1/actual_budgets/:month/:category_id` - Atualizar orçamento

## Serviços

### ActualSyncService
Responsável por sincronizar dados entre o Actual Budget e o sistema PRC.

```ruby
service = ActualSyncService.new(team, actual_db_path)
result = service.sync_all
```

### ActualBankSyncService
Gerencia a sincronização com instituições bancárias.

```ruby
service = ActualBankSyncService.new(actual_account)
result = service.perform_sync
```

## Configuração

1. **Migração do Banco**
   ```bash
   rails db:migrate
   ```

2. **Configurar Team**
   Cada time pode ter suas próprias contas e configurações do Actual.

3. **Importar Dados**
   Use o ActualSyncService para importar dados existentes.

## Segurança

- Credenciais bancárias são criptografadas
- Acesso restrito por team/admin
- Soft delete com campo tombstone
- Auditoria de alterações

## Próximos Passos

1. Implementar importação de arquivo .zip do Actual
2. Criar workers para sincronização automática
3. Desenvolver relatórios financeiros integrados
4. Adicionar webhooks para notificações
5. Implementar reconciliação automática

## Exemplo de Uso

```ruby
# Criar uma conta
account = team.actual_accounts.create!(
  actual_id: 'acc_123',
  name: 'Conta Corrente',
  offbudget: false,
  sync_source: 'simple_fin'
)

# Criar uma transação
transaction = account.actual_transactions.create!(
  actual_id: 'trx_456',
  amount: -5000, # R$ 50,00 em centavos
  date: 20250804,
  payee: payee,
  category: category,
  notes: 'Almoço com cliente'
)

# Adicionar tag
tag = team.actual_tags.find_or_create_by!(tag: 'Despesas Dedutíveis')
transaction.actual_tags << tag
```

## Mapeamento com Sistema Existente

- `ActualAccount` pode ser vinculado a `Account` existente
- `ActualCategory` pode ser mapeado para `Category`
- `ActualPayee` pode ser associado a `Payee` ou `Customer`
- `ActualTransaction` pode gerar `Transaction` no sistema principal

Esta integração permite que escritórios de advocacia mantenham controle financeiro detalhado enquanto aproveitam as funcionalidades avançadas do Actual Budget.
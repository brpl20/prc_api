# frozen_string_literal: true

module Api
  module V1
    # Controller para gerenciar contas do Actual Budget
    class ActualAccountsController < ApplicationController
      before_action :authenticate_admin!
      before_action :set_team
      before_action :set_actual_account, only: [:show, :update, :destroy, :sync]

      def index
        @actual_accounts = @team.actual_accounts
                                .includes(:actual_transactions, :actual_bank_syncs)
                                .active

        render json: @actual_accounts, include: [:recent_transactions]
      end

      def show
        render json: @actual_account, include: [:actual_transactions, :actual_bank_syncs]
      end

      def create
        @actual_account = @team.actual_accounts.build(actual_account_params)

        if @actual_account.save
          render json: @actual_account, status: :created
        else
          render json: { errors: @actual_account.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @actual_account.update(actual_account_params)
          render json: @actual_account
        else
          render json: { errors: @actual_account.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @actual_account.update(tombstone: true)
        head :no_content
      end

      def sync
        service = ActualBankSyncService.new(@actual_account)
        result = service.perform_sync

        if result[:success]
          render json: { message: 'Sync completed successfully', data: result[:data] }
        else
          render json: { errors: result[:errors] }, status: :unprocessable_entity
        end
      end

      def balance_history
        @actual_account = @team.actual_accounts.find(params[:account_id])
        
        history = @actual_account.actual_transactions
                                 .where(date: 30.days.ago.to_i..Date.today.to_i)
                                 .group_by_day { |t| Date.parse(t.date.to_s) }
                                 .sum(:amount)

        render json: { balance_history: history }
      end

      private

      def set_team
        @team = current_admin.current_team
      end

      def set_actual_account
        @actual_account = @team.actual_accounts.find(params[:id])
      end

      def actual_account_params
        params.require(:actual_account).permit(
          :actual_id, :name, :offbudget, :closed, :sort_order,
          :account_id, :sync_source, :bank_name, :official_name
        )
      end
    end
  end
end
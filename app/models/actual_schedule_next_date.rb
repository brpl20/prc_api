# frozen_string_literal: true

# Modelo para próximas datas de agendamento do Actual Budget
class ActualScheduleNextDate < ApplicationRecord
  belongs_to :actual_schedule

  def local_date
    return nil unless local_next_date
    Date.parse(local_next_date.to_s)
  end

  def base_date
    return nil unless base_next_date
    Date.parse(base_next_date.to_s)
  end

  def overdue?
    local_date && local_date < Date.today
  end

  def days_until_due
    return nil unless local_date
    (local_date - Date.today).to_i
  end
end
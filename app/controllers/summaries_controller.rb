class SummariesController < ApplicationController
  def index
    # TODO: add pagination
    @daily_summaries = current_account.daily_summaries.map do |ds|
      DailySummaryPresenter.new(ds)
    end

  end

  def show
    @date = params[:date].to_date
    @account = current_account

    @motds = Motd.where("remove_at >= ?", @date)
    @presenter = DailySummaryPresenter.new(current_account.daily_summaries.where(date: @date).take)
  end
end

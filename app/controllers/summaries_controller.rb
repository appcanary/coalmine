class SummariesController < ApplicationController
  def index
    @daily_summaries = ((Date.today - 70.days)..(Date.today - 69.days)).map do |date|
      DailySummaryQuery.new(current_account, date).create_presenter
    end

  end

  def show
    @date = params[:date].to_date
    @account = current_account

    @motds = Motd.where("remove_at >= ?", @date)
    @presenter = DailySummaryQuery.new(current_account, @date).create_presenter
  end
end

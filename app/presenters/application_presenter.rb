class ApplicationPresenter
  attr_reader :checkins_date_range
  def checkins_date_range
    return { from: nil, to: nil } unless @params[:from].present?
    { from: Date.parse(@params[:from]).beginning_of_day, to: Date.parse(@params[:to]).end_of_day }
  end
end

class Redbox::CheckinsController < ApplicationController

  protect_from_forgery except: :create

  def index
    @checkin_count = Checkin.count
  end

  def show
    checkin = Checkin.find(params[:id])
    unless params[:range] 
      render json: checkin.to_json
    else
      render json: Checkin.order(:id).find(range_array(checkin.id, params[:range].to_i))
    end
  end

  def create
    Checkin.create_from_string(request.body.read, add_device: true)
    render text: "ok"
  end

  private

  def range_array(from, range)
    from = [from]
    (range - 1).times {|x| from << (from.last + 1)}
    from
  end

end

class NicknamesController < ApplicationController
  before_action :admin_user

  def index
    @heroes = Hero.order(:localized_name).includes(:nicknames)
  end

  def new
    @nickname = Hero.find(params[:hero_id]).nicknames.new
  end

  def show
    @nickname = Nickname.find(params[:id])
    render @nickname
  end

  def create
    @nickname = Hero.find(params[:hero_id]).nicknames.new(nickname_params)

    if @nickname.save
      respond_to do |format|
        format.html { redirect_to "index" }
        format.turbo_stream
      end
    else
      render 'new'
    end
  end

  def edit
    @nickname = Nickname.find(params[:id])
  end

  def update
    @nickname = Nickname.find(params[:id])
    
    if @nickname.update(nickname_params)
      render @nickname
    else
      render 'edit'
    end
  end

  def destroy
    Nickname.find(params[:id]).destroy
    render turbo_stream: turbo_stream.remove("nickname_#{params[:id]}")
  end

  private

    def nickname_params
      params.require(:nickname).permit(:name)
    end
end

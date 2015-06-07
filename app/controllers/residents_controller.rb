class ResidentsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @residents = policy_scope(Resident)
    authorize Resident
  end

  def show
    @resident = Resident.find(params[:id])
    authorize @resident
  end

  def edit
    @resident = Resident.find(params[:id])
    authorize @resident
    if @resident.user.blank?
      @resident.build_user
    end
  end

  def update
    @resident = Resident.find(params[:id])
    authorize @resident
    if params[:resident][:user_attributes][:email].blank?
      params[:resident].delete(:user_attributes)
    end
    if @resident.update_attributes(secure_params)
      redirect_to resident_path(@resident), :notice => "Resident updated."
    else
      render :edit
    end
  end

  def new
    @community = Community.find(params[:community_id])
    @resident = Resident.new
    @resident.build_user
  end

  def create
    @community = Community.find(params[:community_id])
    if params[:resident][:user_attributes][:email].blank?
      params[:resident].delete(:user_attributes)
    end
    @resident = @community.residents.build(secure_params)
    if @resident.save
      redirect_to community_path(@resident.community), :notice => "Resident Created."
    else
      render :edit
    end
  end

  def destroy
    @resident = Resident.find(params[:id])
    authorize @resident
    @resident.destroy
    redirect_to residents_path, :notice => "Resident deleted."
  end

  private

  def secure_params
    params.require(:resident).permit(:name, user_attributes: [:id, :email, :password])
  end

end
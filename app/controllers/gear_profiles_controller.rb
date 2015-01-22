class GearProfilesController < ApplicationController
  before_action :set_gear_profile, only: [:show, :edit, :update, :destroy]

  # GET /gear_profiles
  # GET /gear_profiles.json
  def index
    @gear_profiles = GearProfile.all
  end

  # GET /gear_profiles/1
  # GET /gear_profiles/1.json
  def show
  end

  # GET /gear_profiles/new
  def new
    @gear_profile = GearProfile.new
  end

  # GET /gear_profiles/1/edit
  def edit
  end

  # POST /gear_profiles
  # POST /gear_profiles.json
  def create
    @gear_profile = GearProfile.new(gear_profile_params)

    respond_to do |format|
      if @gear_profile.save
        format.html { redirect_to @gear_profile, notice: 'Gear profile was successfully created.' }
        format.json { render :show, status: :created, location: @gear_profile }
      else
        format.html { render :new }
        format.json { render json: @gear_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gear_profiles/1
  # PATCH/PUT /gear_profiles/1.json
  def update
    respond_to do |format|
      if @gear_profile.update(gear_profile_params)
        format.html { redirect_to @gear_profile, notice: 'Gear profile was successfully updated.' }
        format.json { render :show, status: :ok, location: @gear_profile }
      else
        format.html { render :edit }
        format.json { render json: @gear_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gear_profiles/1
  # DELETE /gear_profiles/1.json
  def destroy
    @gear_profile.destroy
    respond_to do |format|
      format.html { redirect_to gear_profiles_url, notice: 'Gear profile was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gear_profile
      @gear_profile = GearProfile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gear_profile_params
      params.require(:gear_profile).permit(:name)
    end
end

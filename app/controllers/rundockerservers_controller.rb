class RundockerserversController < ApplicationController
  before_action :set_rundockerserver, only: [:show, :edit, :update, :destroy]

  # GET /rundockerservers
  # GET /rundockerservers.json
  def index
    @rundockerservers = Rundockerserver.all
  end

  # GET /rundockerservers/1
  # GET /rundockerservers/1.json
  def show
  end

  # GET /rundockerservers/new
  def new
    @rundockerserver = Rundockerserver.new
  end

  # GET /rundockerservers/1/edit
  def edit
  end

  # POST /rundockerservers
  # POST /rundockerservers.json
  def create
    @rundockerserver = Rundockerserver.new(rundockerserver_params)
    respond_to do |format|
      if @rundockerserver.save
        format.html { redirect_to @rundockerserver, notice: 'Rundockerserver was successfully created.' }
        format.json { render :show, status: :created, location: @rundockerserver }
      else
        format.html { render :new }
        format.json { render json: @rundockerserver.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rundockerservers/1
  # PATCH/PUT /rundockerservers/1.json
  def update
    respond_to do |format|
      if @rundockerserver.update(rundockerserver_params)
        format.html { redirect_to @rundockerserver, notice: 'Rundockerserver was successfully updated.' }
        format.json { render :show, status: :ok, location: @rundockerserver }
      else
        format.html { render :edit }
        format.json { render json: @rundockerserver.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rundockerservers/1
  # DELETE /rundockerservers/1.json
  def destroy
    @rundockerserver.destroy
    respond_to do |format|
      format.html { redirect_to rundockerservers_url, notice: 'Rundockerserver was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rundockerserver
      @rundockerserver = Rundockerserver.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rundockerserver_params
      params.require(:rundockerserver).permit(:run_id, :dockerserver_id, :image_id, :jobcount)
    end
end

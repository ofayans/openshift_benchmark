class DockerserversController < ApplicationController
  before_action :set_dockerserver, only: [:show, :edit, :update, :destroy]

  # GET /dockerservers
  # GET /dockerservers.json
  def index
    @dockerservers = Dockerserver.all
  end

  # GET /dockerservers/1
  # GET /dockerservers/1.json
  def show
  end

  # GET /dockerservers/new
  def new
    @dockerserver = Dockerserver.new
  end

  # GET /dockerservers/1/edit
  def edit
  end

  # POST /dockerservers
  # POST /dockerservers.json
  def create
    @dockerserver = Dockerserver.new(dockerserver_params)

    respond_to do |format|
      if @dockerserver.save
        format.html { redirect_to @dockerserver, notice: 'Dockerserver was successfully created.' }
        format.json { render :show, status: :created, location: @dockerserver }
      else
        format.html { render :new }
        format.json { render json: @dockerserver.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dockerservers/1
  # PATCH/PUT /dockerservers/1.json
  def update
    respond_to do |format|
      if @dockerserver.update(dockerserver_params)
        format.html { redirect_to @dockerserver, notice: 'Dockerserver was successfully updated.' }
        format.json { render :show, status: :ok, location: @dockerserver }
      else
        format.html { render :edit }
        format.json { render json: @dockerserver.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dockerservers/1
  # DELETE /dockerservers/1.json
  def destroy
    @dockerserver.destroy
    respond_to do |format|
      format.html { redirect_to dockerservers_url, notice: 'Dockerserver was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dockerserver
      @dockerserver = Dockerserver.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dockerserver_params
      params.require(:dockerserver).permit(:name, :url)
    end
end

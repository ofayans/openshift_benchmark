require 'descriptive-statistics'
include DescriptiveStatistics
class RunsController < ApplicationController
  before_action :authenticate_user!, :set_run, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!

  # GET /runs
  # GET /runs.json
  def index
    @runs = Run.all
  end

  # GET /runs/1
  # GET /runs/1.json
  def show
  end

  # GET /runs/new
  def new
    @run = Run.new
    @run.rundockerservers.build
  end

  # GET /runs/1/edit
  def edit
  end

  # POST /runs
  # POST /runs.json
  def create
    params = run_params.clone
    pass_plaintxt = params[:password]
    params[:password] = BCrypt::Password.create(params[:password])
    heroku_netrc = nil
    if params["heroku_netrc"]
      heroku_netrc = params["heroku_netrc"].read
    end
    params["heroku_netrc"] = "dummystring"
    # By default run is running :)
    params["status_id"] = 1
    @run = Run.new(params)
    respond_to do |format|
      if @run.save
        @docker_kickstart = DockerKickstartsController.new(@run, params["rundockerservers_attributes"], pass_plaintxt, heroku_netrc)
        number_of_containers = @docker_kickstart.docker_kickstart
        set_run_status(@run[:id], number_of_containers)

        format.html { redirect_to @run, notice: 'Run was successfully created.' }
        format.json { render :show, status: :created, location: @run }
      else
        format.html { render :new }
        format.json { render json: @run.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /runs/1
  # PATCH/PUT /runs/1.json
  def update
    respond_to do |format|
      if @run.update(run_params)
        format.html { redirect_to @run, notice: 'Run was successfully updated.' }
        format.json { render :show, status: :ok, location: @run }
      else
        format.html { render :edit }
        format.json { render json: @run.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /runs/1
  # DELETE /runs/1.json
  def destroy
    @run.destroy
    FileUtils.rm_rf(File.join(ENV['OPENSHIFT_DATA_DIR'], @run[:id].to_s))

    respond_to do |format|
      format.html { redirect_to runs_url, notice: 'Run was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_run
      @run = Run.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def run_params
      params.require(:run).permit(:product_id, :login, :password, :heroku_netrc, :scale, :from_code, :envvars, :gear_profile_id, :app_type_id, :addon_id, :broker, :requestcount, :concurrency, :duration_threshold, :rundockerservers_attributes => [:dockerserver_id, :image_id, :jobcount])
    end

  def set_run_status(run_id, global_counter)
    @runresult = Runresult.new(:run_id => run_id)
    @runresult.update(:no_of_observations => global_counter)
    @run = Run.find_by(:id => run_id)
    fork do
      # Wait for logs to arrive to update the run's status
      finished = false
      failed = false
      while not finished do
        app_creations = Dir.glob(File.join(ENV['OPENSHIFT_DATA_DIR'], run_id.to_s, "app_creation_result*"))
        if app_creations.size < global_counter
          # There should be as many output files as many containers we had
          sleep 10
        else
          # we need to make sure, the last file was successfully written to
          sleep 2
          # Prepare the report
          elapses = []
          app_creations.each do |file|
            descriptor = File.open(file, 'r')
            conts = descriptor.read
            if conts.match "fail"
              failed = true
              break
            end
            elapses << conts.match(/(\d+)/).captures[0].to_i
            descriptor.close
          end
          unless failed == true
            @run.update(status_id: 2) #finished
            @runresult.update(app_creation_mean: elapses.mean.round(1), app_creation_stdev: elapses.standard_deviation.round(2), app_creation_values: elapses.join(', '))
            # Process ab output files before scaling
            request_durations_before_scale = []
            fast_requests_before = 0
            slow_requests_before = 0
            jmeter_outputs_before = Dir.glob(File.join(ENV['OPENSHIFT_DATA_DIR'], run_id.to_s, "jmeter_output_before*"))
            jmeter_outputs_before.each do |file|
              File.open(file, 'r') do |descriptor|
                raw_array = descriptor.readlines # raw array contains a csv header that we want to get rid of
                array = raw_array[1..raw_array.size]
                array.each do |elem|
                  line = elem.split(",")
                  request_durations_before_scale << line[0].to_i
                  if line[5] == "true"
                    fast_requests_before += 1
                  else
                    slow_requests_before += 1
                  end
                end
              end
            end
            total_requests_before = slow_requests_before + fast_requests_before

            @runresult.update(request_duration_before_scaling: request_durations_before_scale.mean.round(1))
            @runresult.update(request_duration_before_scaling_stdev: request_durations_before_scale.standard_deviation.round(2))
            @runresult.update(slow_requests_before_scaling: slow_requests_before*100/total_requests_before)
            if @run.scale
              # Now, since ruby does not support dynamic variable naming, we
              # need to construct a mega-hash
              thehash1 = { 1 => :request_duration_after_1_scaling, 
                          2 => :request_duration_after_2_scaling,
                          3 => :request_duration_after_3_scaling,
                          4 => :request_duration_after_4_scaling,
                          5 => :request_duration_after_5_scaling,
                          6 => :request_duration_after_6_scaling,
                          7 => :request_duration_after_7_scaling,
                          8 => :request_duration_after_8_scaling,
                          9 => :request_duration_after_9_scaling,
                          10 => :request_duration_after_10_scaling
              }
              thehash2 = { 1 => :request_duration_after_1_scaling_stdev, 
                          2 => :request_duration_after_2_scaling_stdev,
                          3 => :request_duration_after_3_scaling_stdev,
                          4 => :request_duration_after_4_scaling_stdev,
                          5 => :request_duration_after_5_scaling_stdev,
                          6 => :request_duration_after_6_scaling_stdev,
                          7 => :request_duration_after_7_scaling_stdev,
                          8 => :request_duration_after_8_scaling_stdev,
                          9 => :request_duration_after_9_scaling_stdev,
                          10 => :request_duration_after_10_scaling_stdev
              }

              thehash3 = { 1 => :slow_requests_after_1_scaling, 
                          2 => :slow_requests_after_2_scaling,
                          3 => :slow_requests_after_3_scaling,
                          4 => :slow_requests_after_4_scaling,
                          5 => :slow_requests_after_5_scaling,
                          6 => :slow_requests_after_6_scaling,
                          7 => :slow_requests_after_7_scaling,
                          8 => :slow_requests_after_8_scaling,
                          9 => :slow_requests_after_9_scaling,
                          10 => :slow_requests_after_10_scaling
              }
              @run.scale.times do |iteration|
                request_durations_after = []
                slow_requests = 0
                fast_requests = 0
                time = iteration + 1

                jmeter_outputs_after = Dir.glob(File.join(ENV['OPENSHIFT_DATA_DIR'], run_id.to_s, "jmeter_output_after_#{time}*"))
                if jmeter_outputs_after.size > 0
                  # It was a scalable app
                  jmeter_outputs_after.each do |file|
                    File.open(file, "r") do |descriptor|
                      raw_array = descriptor.readlines
                      array = raw_array[1..raw_array.size]
                      array.each do |elem|
                        line = elem.split(",")
                        request_durations_after << line[0].to_i
                        if line[5] == "true"
                          fast_requests += 1
                        else
                          slow_requests += 1
                        end
                      end
                    end
                  end
                end
                mean_request_duration = request_durations_after.mean.round(1)
                request_duration_stdev = request_durations_after.standard_deviation.round(2)
                total_requests = fast_requests + slow_requests
                slow_request_percentage = slow_requests * 100 / total_requests
                @runresult.update(thehash1[time] => mean_request_duration)
                @runresult.update(thehash2[time] => request_duration_stdev)
                @runresult.update(thehash3[time] => slow_request_percentage)
              end
            end
            @run.update(status_id: 2) # Finished
            finished = true
            # End of the report
          else
            @run.update(status_id: 3) # Failed
          end
        end
      end
    end
  end
end

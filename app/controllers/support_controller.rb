class SupportController < ApplicationController
  def download_results
    run_id = params["id"]
    @run = Run.find_by(:id => run_id)
    @runresult = Runresult.find_by(:run_id => run_id)
    @thehash1 = { 1 => @runresult.request_duration_after_1_scaling, 
                2 => @runresult.request_duration_after_2_scaling,
                3 => @runresult.request_duration_after_3_scaling,
                4 => @runresult.request_duration_after_4_scaling,
                5 => @runresult.request_duration_after_5_scaling,
                6 => @runresult.request_duration_after_6_scaling,
                7 => @runresult.request_duration_after_7_scaling,
                8 => @runresult.request_duration_after_8_scaling,
                9 => @runresult.request_duration_after_9_scaling,
                10 => @runresult.request_duration_after_10_scaling
    }
    @thehash2 = { 1 => @runresult.request_duration_after_1_scaling_stdev, 
                2 => @runresult.request_duration_after_2_scaling_stdev,
                3 => @runresult.request_duration_after_3_scaling_stdev,
                4 => @runresult.request_duration_after_4_scaling_stdev,
                5 => @runresult.request_duration_after_5_scaling_stdev,
                6 => @runresult.request_duration_after_6_scaling_stdev,
                7 => @runresult.request_duration_after_7_scaling_stdev,
                8 => @runresult.request_duration_after_8_scaling_stdev,
                9 => @runresult.request_duration_after_9_scaling_stdev,
                10 => @runresult.request_duration_after_10_scaling_stdev
    }

    @thehash3 = { 1 => @runresult.slow_requests_after_1_scaling, 
                2 => @runresult.slow_requests_after_2_scaling,
                3 => @runresult.slow_requests_after_3_scaling,
                4 => @runresult.slow_requests_after_4_scaling,
                5 => @runresult.slow_requests_after_5_scaling,
                6 => @runresult.slow_requests_after_6_scaling,
                7 => @runresult.slow_requests_after_7_scaling,
                8 => @runresult.slow_requests_after_8_scaling,
                9 => @runresult.slow_requests_after_9_scaling,
                10 => @runresult.slow_requests_after_10_scaling
    }

    filename = "#{run_id}.tar.gz"
    Dir.chdir(ENV['OPENSHIFT_DATA_DIR'])
    if not Dir.glob("*").include?(filename)
      summary_html = render_to_string(:template => "reports/summary.html.erb")
      File.open(File.join(run_id, "summary_report.html"), "w") {|f| f.write(summary_html)}
      system("tar -czf #{filename} #{run_id}")
    end
    file = File.open(filename)
    tarcontents = file.read
    send_data(tarcontents, :filename => "#{run_id}.tar.gz")
  end
end

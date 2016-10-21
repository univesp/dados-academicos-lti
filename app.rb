require 'sinatra'
require 'ims/lti'
require_relative 'lib/log_helper'
require_relative 'lib/main_helper'


configure do
  # Allows Canvas to embed the LTI like a frame
  set :protection, :except => :frame_options
end


  def exec academic_register
    activities_dom = mount_activities_dom academic_register	
    grades_dom = mount_grades_dom academic_register
    rates_dom = mount_rates_dom academic_register
    
    mount_page_dom activities_dom, grades_dom, rates_dom		
  end


get '/' do
  ra = '1501028'
  begin 
    ## Ensures that the request comes from Canvas                
    #return 'Chave de aplicativo inválida' unless authorize params[:oauth_consumer_key]
       
    result = exec ra
    write_log "GET OK. Requester: #{ra}", :info
  rescue Exception => e
    result = { :status => 'EXCEPTION' } 
    write_log "Message: #{e.message}<br><br>Backtrace: #{e.backtrace}", :fatal
  end
  "#{result}"
end


post '/' do
  begin	
    # Ensures that the request comes from Canvas		
    return 'Chave de aplicativo inválida' unless authorize params[:oauth_consumer_key]
    
    academic_register = params[:custom_canvas_user_login_id]
    result = exec academic_register
    write_log "POST OK. Requester: #{academic_register}", :info
  rescue Exception => e
    result = { :status => 'EXCEPTION' }	
    write_log "Message: #{e.message}<br><br>Backtrace: #{e.backtrace}", :fatal
  end
  "#{result}"
end

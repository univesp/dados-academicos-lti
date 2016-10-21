require 'pony'

before do
  #== Log config
  log_amount = 50
  log_size = 10485760 # 10 MB
  # Overwriting Sinatra's default log (env['rack.logger']) 
  env['rack.logger'] = Logger.new( File.join(File.dirname(__FILE__), '../log/app.log'), log_amount, log_size)
  logger.formatter = proc do |severity, datetime, progname, msg|
          "---\n#{datetime}\t#{request.ip}\t#{request.user_agent}\n#{severity}: #{msg}\n"
  end

  #== Mail config
  admin = 'evandro.almeida@univesp.br'	
  Pony.options = { 
    :from => 'no-reply@univesp.br', 
    :to => admin, 
    :headers => { 'Content-Type' => 'text/html; charset=utf-8' }, 
    :via => :smtp, 
    :via_options => { # Postfix
      :address => '10.32.34.6', 
      :port => 25, 
      :enable_starttls_auto => false, 
      :domain => 'mx.cursos.univesp.br'
    } 
  }
end

helpers do
	
  # Writes the given message in the log and, depending on the level, 
  # sends an e-mail to administrators.
  # 
  # @param [String] msg Message to be written
  # @param [Symbol] level Level of severity (debug, warn, info, error or fatal)
  def write_log msg, level
    case level.to_s
      when :debug.to_s
      	logger.debug msg
      when :warn.to_s
        logger.warn msg
      when :error.to_s
        logger.error msg
        Pony.mail(:subject => 'APPS :: "ERROR" in AVA-ACADEMIC-RECORDS', :body => msg)
      when :fatal.to_s
        logger.fatal msg
        Pony.mail(:subject => 'APPS :: "FATAL" in AVA-ACADEMIC-RECORDS', :body => msg)
      else
        logger.info msg
    end
  end

end

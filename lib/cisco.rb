class Cisco < Net::Telnet
  
  attr_accessor :verbose
  
  # set our variables, open the connection, and login if a password is provided
  def initialize(host, login = nil, enable = nil, verbose = false)
    @verbose = verbose
    @host = host
    @login = login
    @enable = enable
    @prompt = /[#>] \z/n
    super("Host" => @host, "Prompt" => @prompt)
    waitfor("String" => "Password:")
    login if @login
  end
  
  # if @verbose is set, 
  def verbose_out
    
  end
  # set variable to new pw if one is passed in and send it to the device. once the prompt is returned we are 'logged in'
  def login(password = nil)
    @login = password || @login
    raise ArgumentError.new("No password given!") unless @login
    puts @login
    waitfor(@prompt)
    @logged_in = true
  end

  def enable(password)
    
  end
  
  
  # logout of the device and close socket
  def close
    (puts "exit" and @enabled = false) if @enabled
    (puts "exit" and @logged_in = false) if @logged_in
    super
  end

end
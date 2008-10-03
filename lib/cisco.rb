class Cisco < Net::Telnet
  
  # set our variables, open the connection, and login if a password is provided
  def initialize(host, login = nil, enable = nil, debug = false)
    @host = host
    @login = login
    @enable = enable
    @debug = debug
    @prompt = /[#>] \z/n
    super("Host" => @host, "Prompt" => @prompt)
    waitfor("String" => "Password:")
    login if @login
  end
  
  # set variable to new pw if one is passed in and send it to the device. once the prompt is returned we are 'logged in'
  def login(password = nil)
    @login = password || @login
    raise ArgumentError.new("No login password given!") unless @login
    puts @login
    waitfor(@prompt)
    @logged_in = true
  end

  def enable(password = nil)
    @enable = password || @enable
    raise ArgumentError.new("No enable password given!") unless @enable
    puts "enable"
    waitfor("String" => "Password:")
    puts @enable
    waitfor(@prompt)
    @enabled = true
  end
  
  
  # logout of the device and close socket
  def close
    (puts "exit" and @enabled = false) if @enabled
    (puts "exit" and @logged_in = false) if @logged_in
    super
  end

  # methods to toggle debug output
  def debug_on
    @debug = true
  end
  
  def debug_off
    @debug = false
  end
  
  private
  # if @debug is true, send passed text to stdout
  def debug_out(output)
    $stdout.puts output if @debug
  end
  
  def puts(txt)
    debug_out(txt)
    super(txt)
  end

end
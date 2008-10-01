class Cisco < Net::Telnet
  
  def initialize(host, login = nil, enable = nil)
    @host = host
    @login = login
    @enable = enable
    @prompt = /[#>] \z/n
    super("Host" => @host, "Prompt" => @prompt)
    login if @login
  end
  
  def login(password = nil)
    raise unless password || @login
    waitfor("String" => "Password:")
    puts password || @login
  end

  def enable(password)
    
  end

end
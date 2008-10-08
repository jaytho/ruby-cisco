require 'net/telnet'

module Cisco
  
  class CiscoError < StandardError
  end

  class Base < Net::Telnet   
    
    # Our constructor opens the connection and attempts to login if a password is specified here.
    # The options that can be used are as follows:
    # * Host (String): This is required. Can contain either an IP address or a domain name.
    # * Login (String): 'Login' password for the device. If present, we will attempt to login upon connecting.
    # * Enable (String): 'Enable' password for the device. Allows us to use enable() without having to pass a password every time.
    # * Debug (Boolean): Pass true or false here to enable verbose output of the session to stdout.
    # * Port (Integer): Specify the port to connect on. Default is 23.
    #
    # A block can be given to be yielded status messages about the connection attempt.
    def initialize(host, loginpw = nil, enablepw = nil, debug = false, port = 23)
      @host = host
      @login = loginpw
      @enable = enablepw
      @debug = debug
      @port = port
      @logged_in = false
      @enabled = false
      @prompt = /[#>]\z/n
      if block_given?
        super("Host" => @host, "Prompt" => @prompt, "Port" => port) {|statmsg| yield statmsg}
      else
        super("Host" => @host, "Prompt" => @prompt, "Port" => port)
      end
      expect("Password:")
      login if @login
    end
    
    # This is meant to be redefined in subclasses to send commands like 'terminal length 0' upon connecting.
    def extra_init
    end
    
    # Returns true or false depending on whether our login attempt appears to have succeeded.
    def logged_in?
      return @logged_in
    end

    # Returns true if enable() has succeeded.
    def enabled?
      return @enabled
    end

    # document this
    def cmd(txt)
      puts(txt)
      expect(@prompt)
    end
    
    # This uses the login password given in the constructor if one is not passed here.
    # If one is passed here, it will take the place of the previous one and be stored for future use.
    # This method sends the password and then waits to see a '>' prompt from the device.
    # If it succeeds, logged_in? will return true from then on.
    def login(password = nil)
      raise CiscoError.new("It looks like we're already logged in!") if logged_in?
      @login = password || @login
      raise ArgumentError.new("No login password given!") unless @login
      puts @login
      expect(">")
      @logged_in = true
      extra_init
    end

    # Same idea as login. Sends the enable password and waits for '#' prompt.
    # enabled? will return true if this succeeds.
    def enable(password = nil)
      @enable = password || @enable
      raise ArgumentError.new("No enable password given!") unless @enable
      puts "enable"
      expect("Password:")
      puts @enable
      expect("#")
      @enabled = true
    end

    # This logs out of the device by sending 'exit': 
    # * once if logged in 
    # * twice if enabled 
    # and closes the socket.
    def close
      (puts "exit" and @enabled = false) if @enabled
      (puts "exit" and @logged_in = false) if @logged_in
      super
    end

    # This is an easier to use version of waitfor(). It can be passed a String or Regexp to be used as the match
    # criteria, or a Hash of the same options that waitfor() takes.
    # 
    # Just like waitfor(), this can take a block which will be yielded the received data.
    # If a block is omitted, the default behavior is to pass received data to stdout if debug is enabled.
    def expect(args)
      if block_given?
        if args.is_a?(String)
          waitfor("String" => args) {|recvdata| yield recvdata} 
        elsif args.is_a?(Regexp)
          waitfor(args) {|recvdata| yield recvdata}
        elsif args.is_a?(Hash)
          waitfor(args) {|recvdata| yield recvdata}
        end
      else
        if args.is_a?(String)
          waitfor("String" => args) {|recvdata| debug_out(recvdata)}
        elsif args.is_a?(Regexp)
          waitfor(args) {|recvdata| debug_out(recvdata)}
        elsif args.is_a?(Hash)
          waitfor(args) {|recvdata| debug_out(recvdata)}
        end
      end
    end
    
    # Turns on debug output.
    def debug_on
      @debug = true
    end

    # Turns off debug output.
    def debug_off
      @debug = false
    end

    private
    # if @debug is true, send passed text to stdout
    def debug_out(output)
      $stdout.print output if @debug
    end

  end

end
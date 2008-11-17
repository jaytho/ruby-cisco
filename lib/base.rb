require 'ostruct'

module Cisco
    
  class CiscoError < StandardError
  end
  
  class Group < OpenStruct
    def to_a
      @table.inject([]) {|result, pair| result << pair.last; result }
    end
  end

  class Base
    
    attr_reader :info, :ints, :host
    
    def initialize(host, loginpw, enablepw, transport = Telnet, options = {})
      @prompt = /[#>]\s?\z/n
      @login = loginpw
      @enable = enablepw
      @transport = transport.new(host, options)
      [@logged_in, @enabled, @confmode].each {|var| var = false}
      @transport.expect("Password:")
      login if @login
      extra_init
    end
    
    # This is meant to be redefined in subclasses to send initial commands like 'terminal length 0' upon connecting.
    def extra_init
    end

        # document this and add block passing
    def cmd(txt)
      @transport.puts(txt)
      return @transport.expect(@prompt)
    end
    
    # This uses the login password given in the constructor if one is not passed here.
    # If one is passed here, it will take the place of the previous one and be stored for future use.
    # This method sends the password and then waits to see a '>' prompt from the device.
    # If it succeeds, logged_in? will return true from then on.
    def login(password = nil)
      raise CiscoError.new("It looks like we're already logged in!") if logged_in?
      @login = password || @login
      raise ArgumentError.new("No login password given!") unless @login
      @transport.puts @login
      @transport.expect(@prompt)
      @logged_in = true
    end
    
    # Same idea as login. Sends 'enable', then the enable password and waits for '#' prompt.
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
    
    def configure
      enable unless enabled?
      cmd("configure terminal")
      @confmode = true
    end
    
    def confmode?
      return @confmode
    end

    # Returns true or false depending on whether our login attempt appears to have succeeded.
    def logged_in?
      return @logged_in
    end

    # Returns true if enable() has succeeded.
    def enabled?
      return @enabled
    end
    
    def	puts(txt)
    	@transport.puts(txt)
    end
    
    def expect(txt)
    	@transport.expect(txt)
    end
    
    # This logs out of the device by sending 'exit': 
    # * once if logged in 
    # * twice if enabled 
    # and closes the socket.
    def close
      (puts "exit" and @enabled = false) if @enabled
      (puts "exit" and @logged_in = false) if @logged_in
      @transport.close
    end
    
    # Turns on debug output.
    def debug_on
      @transport.debug_on
    end

    # Turns off debug output.
    def debug_off
      @transport.debug_off
    end

  end
  
end

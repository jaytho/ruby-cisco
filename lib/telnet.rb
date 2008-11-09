require 'net/telnet'

module Cisco

  class Telnet < Net::Telnet   
    
    # Our constructor opens the connection and attempts to login if a password is specified here.
    # The options that can be used are as follows:
    # * Host (String): This is required. Can contain either an IP address or a domain name.
    # * Login (String): 'Login' password for the device. If present, we will attempt to login upon connecting.
    # * Enable (String): 'Enable' password for the device. Allows us to use enable() without having to pass a password every time.
    # * Debug (Boolean): Pass true or false here to enable verbose output of the session to stdout.
    # * Port (Integer): Specify the port to connect on. Default is 23.
    #
    # A block can be given to be yielded status messages about the connection attempt.
    def initialize(host, options = {})
      @host = host
      @port = options[:port] || 23
      if block_given?
        super("Host" => @host, "Port" => @port) {|statmsg| yield statmsg}
      else
        super("Host" => @host, "Port" => @port)
      end
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
    
    def	debug_on
    	@debug = true
    end
    
    def	debug_off
    	@debug = false
    end

    private
    # if @debug is true, send passed text to stdout
    def debug_out(output)
      $stdout.print output if @debug
    end

  end

end

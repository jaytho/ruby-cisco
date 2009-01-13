require 'net/telnet'

module Cisco

  class Telnet
    
    include Common

    def initialize(options)
      @host    = options[:host]
      @password = options[:password]
      @prompt  = options[:prompt]
      @targs   = options[:directargs] || ["Host" => @host]
		  @pwprompt = options[:pwprompt] || "Password:"
      @cmdbuf, @extra_init = [], []
    end

    def run
      @results = []
      (@cmdbuf = [] and yield self) if block_given?
      @cmdbuf.insert(0, *@extra_init) if @extra_init.any?
      @telnet = Net::Telnet.new(*@targs)
      login
      until @cmdbuf.empty?
        send_next
        @results << @telnet.waitfor(@prompt) {|x| @outblock.call(x) if @outblock}
      end
      
      @results
    end

    def cmd(cmd, prompt = nil, &block)
      @cmdbuf << [cmd, prompt, block]
    end
    
    def close
      10.times do
        chn.send_data("exit\n") while @telnet.sock
      end
    end

    private

    def login
      raise CiscoError.new("No login password provided.") unless @password
      @results << @telnet.waitfor(Regexp.new("Password:"))
      @telnet.puts(@password)
      @results << @telnet.waitfor(@prompt)
    end

    def	send_next
      cmd = @cmdbuf.shift
      @prompt = Regexp.new(cmd[1]) if cmd[1]
      @outblock = cmd[2] if cmd[2]
      @telnet.puts(cmd.first)
    end

  end

end
require 'rubygems'
require 'net/ssh'
require 'timeout'
require 'thread'

module Cisco

  class SSH

    attr_reader :chan, :ssh, :thread

    def initialize(*args)
      @buf = ""
      @thread = Thread.new {
        @loop = true
        @ssh = Net::SSH.start(*args)
        @chan = @ssh.open_channel {|chan| chan.send_channel_request("shell"); chan.on_data {|ch, data| @buf << data; $stdout.puts data} }
        @ssh.loop { @loop }
      }
    end

    def puts(data)
      @chan.send_data(data)
    end

    # Look at Telnet and IO's expect to see how this is done
    def expect(prompt)
      Timeout::timeout(10) {
        while true
          return @buf if @buf =~ prompt
        end
      }
    end

    def close
      @ssh.close
    end

  end # class SSH

end # module Cisco
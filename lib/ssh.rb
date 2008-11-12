require 'rubygems'
require 'net/ssh'
require 'timeout'
require 'thread'

module Cisco

  class SSH

    attr_reader :chan, :ssh, :thread, :buf

    def initialize(*args)
      @buf = []
      @ssh = Net::SSH.start(*args)
      @loop = true
      #@thread = Thread.new {
      	@ssh.open_channel do |chan|
      	chan.on_data {|ch, data| @buf << data; $stdout.puts data }
      	chan.send_channel_request("shell");
      	chan.send_data("terminal length 0\nsh ver\n")
      end
        @ssh.loop { @loop }
      #}
    end

    def puts(txt)
      @ssh.open_channel do |chan|
      	chan.send_channel_request("shell");
      	chan.on_data {|ch, data| @buf << data; $stdout.puts data }
      	chan.send_data(txt)
      end
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

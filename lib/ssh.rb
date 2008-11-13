require 'rubygems'
require 'net/ssh'
require 'timeout'
require 'thread'

module Cisco

  class SSH < Thread

    attr_reader :chan, :ssh, :thread, :buf

    def initialize(*args)
      @buf = ""
      @ssh = Net::SSH.start(*args)
	super
    end

    def puts(txt)
	@loop = true
      @ssh.open_channel do |chan|
	chan.on_process {|ch| (chan.close && @loop = false) if @buf =~ /[#>]\s?\z/n }
      	chan.send_channel_request("shell") do |ch, success|
		ch.on_data {|ch, data| @buf << data; STDOUT.puts data }
		ch.send_data(txt + "\n")
	end

      end
	@ssh.loop { @loop }
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

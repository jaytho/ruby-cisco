require 'rubygems'
require 'net/ssh'

class Net::SSH::Connection::Channel

	def cmd(cmd, prompt = nil, &block)
		self[:cmdbuf] << [cmd + "\n", prompt, block]
	end

	def enable(password, pwprompt = nil)
		old = self[:prompt]
		cmd("enable", pwprompt || "Password:")
		cmd(password, old)
	end
	
	def check_and_send
		if self[:inbuf] =~ self[:prompt]
			self[:results] << self[:inbuf]
			self[:inbuf] = ""
			if self[:cmdbuf].any?
				send_next
			else
				close
			end
		end
	end
	
	def	send_next
		cmd = self[:cmdbuf].shift
		self[:prompt] = Regexp.new(cmd[1]) if cmd[1]
		self[:outblock] = cmd[2] if cmd[2]
		send_data(cmd.first)
	end
	
end # class Net::SSH::Connection::Channel

module Cisco

	class SSH
	
		attr_accessor :prompt
	
		def initialize(*args)
			@sshargs = args
		end

		def run
			@ssh = Net::SSH.start(*@sshargs)
			@ssh.open_channel do |chan|
				chan.send_channel_request("shell") do |ch, success|
					if !success
						abort "Could not open shell channel"
					else
						ch[:cmdbuf], ch[:results] = [], []
						ch[:inbuf] = ""
						ch[:prompt] = @prompt
						ch.on_close {|ch| @results = ch[:results] }
						ch.on_data do |chn, data|
							chn[:outblock].call(data) if chn[:outblock]
							chn[:inbuf] << data
							chn.check_and_send
						end
						yield ch
					end
				end
			end
			@ssh.loop
			return @results
		end

	end # class SSH
	
end # module Cisco

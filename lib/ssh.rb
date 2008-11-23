require 'rubygems'
require 'net/ssh'

class Net::SSH::Connection::Channel

	def cmd(cmd, prompt = /[#>]\s?\z/n, &block)
		self[:cmdbuf] << [cmd + "\n", Regexp.new(prompt), block]
	end

	def enable(password)
		cmd("enable", "Password:")
		cmd(password)
	end
	
	def check_and_send
		if self[:inbuf] =~ @prompt
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
		@prompt = cmd[1]
		self[:outblock] = cmd[2] if cmd[2]
		send_data(cmd.first)
	end
	
end

module Cisco

	class SSH
	
		def initialize(*args)
			@sshargs = args
		end

		def run
			@ssh = Net::SSH.start(*@sshargs)
			@ssh.open_channel do |chan|
				chan.send_channel_request("shell") do |ch, success|
					if !success
						raise "Could not open shell channel"
					else
						ch[:cmdbuf] = []
						ch[:results] = []
						ch[:inbuf] = ""
						ch.on_close {|ch| @results = ch[:results] }
						ch.on_data do |ch, data|
							ch[:outblock].call(data) if ch[:outblock]
							ch[:inbuf] << data
							ch.check_and_send
						end
						yield ch
						ch.send_next
					end
				end
			end
			@ssh.loop
			return @results
		end

	end # class SSH
	
end # module Cisco

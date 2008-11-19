require 'rubygems'
require 'net/ssh'

module Cisco

	class SSH
	
		def initialize(*args)
			@ssh = Net::SSH.start(*args)
			@ssh.open_channel do |chan|
				chan.send_channel_request("shell") do |ch, success|
					if !success
						raise "Could not open shell"
					else
						yield ch
					end
				end
			end
			@ssh.loop
		end

	end # class SSH
	
end # module Cisco

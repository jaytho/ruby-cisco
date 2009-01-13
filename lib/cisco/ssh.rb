require 'net/ssh'

module Cisco

	class SSH
	  
	  include Common
	
		def initialize(options)
		  @host    = options[:host]
		  @user    = options[:user]
		  @password = options[:password]
		  @prompt  = options[:prompt]
		  @sshargs = options[:directargs] || [@host, @user, {:password => @password, :auth_methods => ["password"]}]
		  @pwprompt = options[:pwprompt] || "Password:"
		  @cmdbuf, @extra_init = [], []
		end
   	
   	def cmd(cmd, prompt = nil, &block)
			@cmdbuf << [cmd + "\n", prompt, block]
		end
		
		def run
			@inbuf = ""
			@results = []
			@ssh = Net::SSH.start(*@sshargs)
			@ssh.open_channel do |chan|
				chan.send_channel_request("shell") do |ch, success|
					if !success
						abort "Could not open shell channel"
					else
						ch.on_data do |chn, data|
							@outblock.call(data) if @outblock
							@inbuf << data
							check_and_send(chn)
						end
						(@cmdbuf = [] and yield self) if block_given?
						@cmdbuf.insert(0, *@extra_init) if @extra_init.any?
					end
				end
			end
			@ssh.loop
			
			@results
		end
		
		# Disconnect the session. Either Net::SSH has a bug, or the Cisco implementation is sometimes whacky,
		# causing an exception to be thrown when trying to close the channel via the SSH protocol. To get around
		# this, this method simply sends "exit" until the device disconnects us.
		def close(chn)
      10.times do
        chn.send_data("exit\n") unless (!chn.active? || chn.closing?)
      end
    end
		
		private
				
		def check_and_send(chn)
			if @inbuf =~ @prompt
				@results << @inbuf.gsub(Regexp.new("\r\n"), "\n")
				@inbuf = ""
				if @cmdbuf.any?
					send_next(chn)
				else
					close(chn)
				end
			elsif (@inbuf =~ Regexp.new(@pwprompt) and @prompt != Regexp.new(@pwprompt))
				@cmdbuf = []
				close(chn)
				raise CiscoError.new("Enable password was not correct.")
			end
		end

		def	send_next(chn)
			cmd = @cmdbuf.shift
			@prompt = Regexp.new(cmd[1]) if cmd[1]
			@outblock = cmd[2] if cmd[2]
			chn.send_data(cmd.first)
		end

	end
	
end
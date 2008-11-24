require 'rubygems'
require 'net/ssh'

module Cisco

	class SSH
	
		attr_accessor :prompt, :password, :host
	
		def initialize(options)
		  @host    = options[:host]
		  @user    = options[:user]
		  @password = options[:password]
		  @prompt  = options[:prompt] || /[#>]\s?\z/n
		  @sshargs = options[:directargs] || [@host, @user, {:password => @password}]
		  @pwprompt = "Password:"
		  @cmdbuf, @results = [], []
		end

		def cmd(cmd, prompt = nil, &block)
			@cmdbuf << [cmd + "\n", prompt, block]
		end
		
		def enable(password, pwprompt = nil)
			@pwprompt = pwprompt || @pwprompt
			old = @prompt
			cmd("enable", @pwprompt)
			cmd(password, old)
		end
		
		def extra_init(&block)
		  @extra_init = block
		end
		
		def run
			@inbuf = ""
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
						@extra_init.call(self) if @extra_init
						(@cmdbuf = [] and yield self) if block_given?
					end
				end
			end
			@ssh.loop
			results = @results
			@cmdbuf, @results = [], []
			return results
		end
		
		private
		
		def check_and_send(chn)
			if @inbuf =~ @prompt
				@results << @inbuf
				@inbuf = ""
				if @cmdbuf.any?
					send_next(chn)
				else
					chn.close
				end
			elsif (@inbuf =~ Regexp.new(@pwprompt) and @prompt != Regexp.new(@pwprompt))
				chn.close
				raise ArgumentError.new("Enable password was not correct.")
			end
		end

		def	send_next(chn)
			cmd = @cmdbuf.shift
			@prompt = Regexp.new(cmd[1]) if cmd[1]
			@outblock = cmd[2] if cmd[2]
			chn.send_data(cmd.first)
		end

	end # class SSH
	
end # module Cisco

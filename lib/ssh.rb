require 'rubygems'
require 'net/ssh'
require 'timeout'
require 'thread'

module Cisco

  class SSH

	# Just so we can mess with these as we need to for debugging...
    attr_reader :ssh, :thread, :inbuf, :outbuf, :result

    def initialize(*args)
    	@first = true
		@result = @inbuf = @outbuf = ""
		# Tells our thread to continue running
		@threadgo = true
		# Not sure if we need this but just to be safe...
		@sem = Mutex.new
		# generic prompt, should work on most devices for now.
		@prompt = /[#>]\s?\z/n
		# Start the SSH session inside of a thread. The purpose of this whole
		# structure is that we can keep the event loop running inside the thread,
		# while passing new outgoing commands into the @outbuf from the main thread.
		# This hopefully allows the channel to remain open and work pseudo-interactively.
		# Currently not working correctly right now, due to me being a retard.
		@thread = Thread.new {
			Net::SSH.start(*args) do |ssh|
				ssh.open_channel do |chan|
					# Send the shell request
					chan.send_channel_request("shell") do |ch, success|
						# Pass all incoming data to our recv_data method
						ch.on_data {|ch, data| recv_data(data) }
						# The idea is that this checks the @outbuf on every pass of the event loop
						# to see if anything new needs to be sent out. I don't think it is happening
						# correctly right now, though I just did this and haven't tested it much yet.
						ch.on_process {|chn| @sem.synchronize { (chn.send_data(@outbuf) && @outbuf = "") unless @outbuf.empty? } }
					end
	  	    	end
	  	    	# This is _supposed_ to loop forever, even channel is not active.
				ssh.loop { true }
			end
		}
		run
    end

	# All incoming data should be passed to this method through Channel#on_data
    def recv_data(data)
    	# append data to buffer...
		@inbuf << data
		# For debugging purposes
		#STDOUT.puts data
		check_prompt
    end
    
    def	check_prompt
   		# If the buffer contains our prompt
    	if @inbuf =~ @prompt
			# assign it to the @result
			@result = @inbuf
			# reset the buffer
			@inbuf = ""
			# and stop the thread
			@threadgo = false
		end
    end

	# For sending outgoing commands
    def puts(txt)
    	# This just updates the output buffer
		@sem.synchronize { @outbuf = txt + "\n" }
		# and tells the thread with the session to run
		run
    end

    def run
    	# For some reason the thread goes to sleep all the time
    	# while the event loop is running so we need to keep it going?
    	# I wish I understood threading better. This might be something
    	# quirky with the event loop but I'm not sure yet.
		@threadgo = true
		while @threadgo 
			@thread.run
		end
    end

    # Look at Telnet and IO's expect to see how this is done.
    # This is a bit wierd but would probably work if everything else did.
    def expect()
		Timeout::timeout(10) {
			while true
				(return @result && @result = "") if @result =~ @prompt
			end
		}
    end

    def close
		@ssh.close
		@thread.run
		@thread.kill if @thread.alive?
    end

  end # class SSH

end # module Cisco

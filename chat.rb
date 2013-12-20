require 'pandorified'
require 'whatsapp'

PANDORA_BOT = 'b0dafd24ee35a477' # Pandorabot bot-id (in this case http://demo.vhost.pandorabots.com/pandora/talk?botid=b0dafd24ee35a477)
WHATSAPP_NO = '' # Your whatsapp mobile number
WHATSAPP_PW = '' # Your whatsapp password
WHATSAPP_NICK = '' # Your nickname

bots = {}

whatsapp = WhatsApp::Client.new(WHATSAPP_NO, WHATSAPP_NICK, :debug_output => $stdout)
whatsapp.connect()
whatsapp.auth(WHATSAPP_PW)
whatsapp.set_online_presence()

# Welcome to the endless loop of a bot's life
while true

	# Check if there was activity since our last iteration
	whatsapp.poll_messages
	messages = whatsapp.get_messages
	messages.each do |message|
		if message.attribute('type') == 'chat'
			sender = message.attribute('from')

			child = message.child('body')
			unless child.nil?

				# Create a bot instance per communication to keep track of the exchange
				if bots[sender].nil?
					bots[sender] = Pandorified::Session.new(PANDORA_BOT)
				end
				answer = bots[sender].talk!(child.data)

				# Simulate reading and typing behaviour
				sleep (rand*5).floor
				whatsapp.composing_message(sender)
				sleep 5

				# Send our answer
				whatsapp.send_message(sender, answer)
			end
		end
	end

	# Keep their infrastructure's load as low as possible - play fair.
	sleep 5
end

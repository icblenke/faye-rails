module FayeRails
  class Controller
    class Channel

      attr_reader :channel, :endpoint

      def initialize(channel, endpoint=nil)
        @channel = channel
        @endpoint = endpoint
      end

      def client
        FayeRails.client(endpoint)
      end

      def publish(message)
        FayeRails.client(endpoint).publish(channel, message)
      end

      def monitor(event, &block)
        raise ArgumentError, "Unknown event #{event.inspect}" unless [:subscribe,:unsubscribe,:publish].member? event

        server_endpoint=FayeRails.server(endpoint)
	if server_endpoint
	  server_endpoint.bind(event) do |*args|
            FayeRails.server(endpoint).bind(event) do |*args|
              Monitor.new.tap do |m|
                m.client_id = args.shift
                m.channel = args.shift
                m.data = args.shift
                m.instance_eval(&block) if m.channel == channel
              end
            end
          end
        end
      end

      def filter(direction=:any, &block)
        filter = FayeRails::Filter.new(channel, direction, block)
        server = FayeRails.server(endpoint)
        server.add_extension(filter)
        filter.server = server
        filter
      end

      def subscribe(&block)
        EM.schedule do 
          @subscription = FayeRails.client(endpoint).subscribe(channel) do |message|
            Message.new.tap do |m|
              m.message = message
              m.channel = channel
              m.instance_eval(&block)
            end
          end
        end
      end

      def unsubscribe
        EM.schedule do
          FayeRails.client(endpoint).unsubscribe(@subscription)
        end
      end

    end
  end
end

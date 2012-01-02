Dummy::Application.routes.draw do
  faye_server '/faye_without_websockets', :timeout => 25
  faye_server '/faye_with_websockets', :timeout => 25, :enable_websockets => true
  faye_server '/faye_with_extension', :timeout => 25 do
    class MockExtension 
      def incoming(message, callback)
        callback.call(message)
      end
      def outgoing(message, callback)
        callback.call(message)
      end
    end
    add_extension(MockExtension)
  end
end

require "boxen/hook"
require "opentsdb"

module Boxen
  class Hook
    class TSDB < Hook
      def perform?
        enabled?
      end

      private
      def call
        payload = {
          :login  => config.user,
          :sha    => checkout.sha,
          :status => result.success? ? 'success' : 'failure',
        }

        send_opentsdb_data payload
      end

      def send_opentsdb_data(payload)
        host = ENV['BOXEN_OPENTSDB_HOST']
        port = ENV['BOXEN_OPENTSDB_PORT'].to_i

        @client = OpenTSDB::Client.new({:hostname => host, :port => port})

        boxen_run = { :metric => 'boxen.runs', :value => 1, :timestamp => Time.now.to_i, :tags => payload }
        @client.put(boxen_run)
      end

      def required_environment_variables
        ['BOXEN_OPENTSDB_HOST', 'BOXEN_OPENTSDB_PORT']
      end
    end
  end
end

Boxen::Hook.register Boxen::Hook::TSDB

module MongoDatabase
  class << self
    def client
      @client ||= begin
        hosts = [ "#{ENV.fetch('MONGO_HOST', 'localhost')}:#{ENV.fetch('MONGO_PORT', '27017')}" ]
        database = ENV.fetch('MONGO_DATABASE', "restaurant_platform_#{Rails.env}")
        
        Mongo::Logger.logger = Rails.logger
        Mongo::Logger.logger.level = Rails.env.development? ? Logger::INFO : Logger::WARN

        Mongo::Client.new(
          hosts,
          database: database,
          server_selection_timeout: 2,
          connect_timeout: 2,
          socket_timeout: 2,
          max_pool_size: 5
        )
      end
    end

    def audit_collection
      client[:order_audit_logs]
    end

    def reset_client!
      @client&.close rescue nil
      @client = nil
    end
  end
end

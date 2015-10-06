module ServiceNow
    class Configuration
        def self.configure(auth_hash = {})
            $root_url = auth_hash[:sn_url].sub(/(\/)+$/, '') #remove trailing slash if there are any
            $username = auth_hash[:sn_username]
            $password = auth_hash[:sn_password]
            "SN::Success: Configuration successful"
        end

        def self.get_resource(query_hash = {}, table)
            # to be filled
            RestClient::Resource.new(URI.escape($root_url + "/api/now/table/#{table}?sysparm_query=#{hash_to_query(query_hash)}"), :headers => { :accept => "application/json" }, :user => $username, :password => $password)
        end

        def self.post_resource(table)
            RestClient::Resource.new(URI.escape($root_url + "/api/now/table/#{table}?sysparm_action=insert"), $username, $password)
        end

        def self.update_resource(incident_number, table)
           RestClient::Resource.new(URI.escape($root_url + "/api/now/table/#{table}?sysparm_action=update"), $username, $password)
        end

        private
            def self.hash_to_query(query_hash = {})
                if query_hash.empty?
                  # You're gonna have a bad time if you don't pass a query
                  raise "SN::ERROR: You must provide a query!"
                end
                
                query_string = []
                
                # Make sure we're always dealing with an array                
                query_hash = [query_hash] if ! query_hash.is_a?(Array)

                query_hash.each do |f|
                  query_string.push f[:field] + f[:operator] + f[:query]
                end
                
                query_string.join('^')
            end
    end
end
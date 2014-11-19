module ServiceNow
    class Configuration

        def self.configure(auth_hash = {})
            $root_url = auth_hash[:sn_url].sub(/(\/)+$/, '') #remove trailing slash if there are any
            $username = auth_hash[:sn_username]
            $password = auth_hash[:sn_password]
            "SN::Success: Configuration successful"
        end

        # Generates a RestClient resource for the given query
        # Params:
        # +query+:: Either a hash or array of hashes to represent a query.
        #           arrays are joined by ORs, hashes by ANDs
        # +displayvalue+:: true of false ServiceNow display value param
        # +table+:: table to search (e.g. "incident" or "sys_user")
        def self.get_resource(query = {}, displayvalue = false, table)
            query_string = string_from_query(query)
            # to be filled in
            RestClient::Resource.new(URI.escape($root_url + "/#{table}.do?JSON&sysparm_action=getRecords&sysparm_query=#{query_string}&displayvalue=#{displayvalue}"), $username, $password)
        end

        def self.post_resource(table)
            RestClient::Resource.new(URI.escape($root_url + "/#{table}.do?JSON&sysparm_action=insert"), $username, $password)
        end

        def self.update_resource(incident_number, table)
           RestClient::Resource.new(URI.escape($root_url + "/#{table}.do?JSON&sysparm_query=number=#{incident_number}&sysparm_action=update"), $username, $password) 
        end

        private

            # Constructs a ServiceNow sys_parm query from either an array or hash
            # Arrays are joined by ORs and hashes are joined by ANDs
            # Params:
            # +query+:: Either an array or a hash representing a query
            def self.string_from_query(query = {})
                query_string = ""
                if query.is_a?(Array)
                    query_string = query.map {|q| hash_to_query(q)}.join('^OR')
                else
                    query_string = hash_to_query(query)
                end
                return query_string
            end

            def self.hash_to_query(query_hash = {})
                if query_hash.empty?
                    return ""
                end
                query_string = []
                query_hash.each do |k, v|
                    key_str = k.to_s
                    value_str = v.to_s
                    # if we are querying based on short_description or description
                    # we use a partial match
                    if key_str == "short_description" || key_str == "description"
                        query_string << key_str + "LIKE" + value_str
                    else
                        query_string << key_str + "=" + value_str
                    end
                end
                query_string.join('^')
            end
    end
end
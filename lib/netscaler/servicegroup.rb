module Netscaler
  class ServiceGroup < NSStateBaseObject
    attr_reader :name, :params
      
    def initialize(nitro, name, options)
      required = ["servicetype"]
      @options = ["servicetype", "maxclient", "cip", "cipheader", "usip", "downstateflush", "sc", "sp", "srvtimeout", "clttimeout", "useproxyport", "tcpb", "comment", "state", "cmp", "maxreq", "appflowlog" ] 
      @type = "servicegroup"
      @nsname_key = "servicegroupname"

      raise ArgumentError, "name should a String" unless name.is_a? String
      raise ArgumentError, "options must be a Hash" unless options.is_a? Hash
      
      options.keys.each { |k| raise ArgumentError, "unknown key (arg:3) : #{k}" unless @options.include? k }
      required.each { |k| raise ArgumentError, "the Hash doesn't have the required keys (arg:3) : should have #{required.to_s}, had => #{options.keys.to_s}" unless options.include? k }
      
      @nitro = nitro
      @name = name
      @params = {}
      options.each do |k,v|
        @params[k] = v
      end
      
      @params["state"] = "ENABLED" unless @params.has_key? "state"
    end

    def bind(options)
      raise ArgumentError, "argument must be an Array" unless options.is_a? Array
      
      required_attrs = ["servername", "port"]
      avail_attrs = ["serverid", "hashid", "weight"]
      
      options.each do |option|
        required_attrs.each {|attr| raise ArgumentError, "the Hash doesn't have the required keys (arg:1) : should have #{required_attrs.to_s}" unless option.include? attr }
        option.keys.each {|k| raise ArgumentError, "unknown key (arg:1) : #{k}" unless avail_attrs.include?(k) or required_attrs.include?(k) }
      end
      
      send_action("bind", options)
    end
    
    def unbind(options)
      raise ArgumentError, "argument must be an Array" unless options.is_a? Array
      
      attrs = ["servername", "port"]
      options.each do |option|
        attrs.each {|attr| raise ArgumentError, "the Hash doesn't have the required keys (arg:1) : should have #{attrs.to_s}" unless option.include? attr }
      end
      
      send_action("unbind", options)
    end

    def list_servers
      result = @nitro.get("servicegroup_servicegroupmember_binding/#{@name}")
      
      if result
        result = result.has_key?("servicegroup_servicegroupmember_binding") ? result["servicegroup_servicegroupmember_binding"] : []
        
        result.each {|server| server.delete @nsname_key }
      end
      
      result
    end
    
    def enable_server(options)
      raise ArgumentError, "argument must be an Hash" unless options.is_a? Hash
      
      attrs = ["servername", "port"]
      attrs.each {|attr| raise ArgumentError, "the Hash doesn't have the required keys (arg:1) : should have #{attrs.to_s}" unless options.include? attr }
      
      send_action("enable", options)
    end
    
    def disable_server(options)
      raise ArgumentError, "argument must be an Hash" unless options.is_a? Hash
      
      attrs = ["servername", "port"]
      attrs.each {|attr| raise ArgumentError, "the Hash doesn't have the required keys (arg:1) : should have #{attrs.to_s}" unless options.include? attr }
      
      send_action("disable", options)
    end
   
    def update!(params)
      raise ArgumentError, "argument must be a Hash" unless params.is_a? Hash
      
      immutable = "servicetype"
      raise ArgumentError, "#{immutable} key is immutable" if params.has_key? immutable
      
      if params.has_key? "cip"
        if params["cip"] == "ENABLED" and not params.has_key? "cipheader"
          if @params.has_key? "cipheader"
            params["cipheader"] = @params["cipheader"] if @params.has_key? "cipheader"
          else params.has_key? "cipheader"
            raise ArgumentError, 'key "cipheader" cannot exist without key "cip" set to "YES" and vice versa'
          end
        end
      end
    
      super params
    end
   
    def self.get_options
      ["servicetype", "maxclient", "cip", "cipHeader", "usip", "downstateflush", "sc", "sp", "srvtimeout", "clttimeout", "useproxyport", "tcpb", "comment", "state", "cmp", "maxreq", "appflowlog" ]
    end
    
    def self.get_type
      "servicegroup"
    end
    
    def self.get_nsname_key
      "servicegroupname"
    end
    
  end
end
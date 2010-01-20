require File.dirname(__FILE__) + '/ipaddr_list'

module ActionController
  module IpAuth
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    class Config
      attr_reader :options
      attr_reader :ip_list
   
      def initialize(options)
        @options = {
          :ip_list => %w(127.0.0.1)
        }.merge(options)
        
        @ip_list = self.options[:ip_list].to_a
        @ip_list = IPAddrList.new(@ip_list) unless @ip_list.empty?
      end
    end
    
    module ClassMethods
      def authenticates_ip(options = {}, filter_options = {})
        @ip_auth_config = ActionController::IpAuth::Config.new(options)
        
        before_filter :authenticate_ip, filter_options
        
        include ActionController::IpAuth::InstanceMethods        
      end
      
      def ip_auth_config
        @ip_auth_config || self.superclass.instance_variable_get('@ip_auth_config')
      end
    end
  
    module InstanceMethods      
      protected
      
      def authenticate_ip
        unless self.class.ip_auth_config.ip_list.include?(request.ip)
          render :text => 'Access denied', :status => "403 Forbidden"
        end    
      end      
    end
  
  end
end

::ActionController::Base.send(:include, ActionController::IpAuth)

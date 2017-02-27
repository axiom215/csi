# frozen_string_literal: true
require 'net/ldap'

module CSI
  module Plugins
    # This plugin is a data access object used for interacting w/ Active Directory/LDAP Servers
    module DAOLDAP
      # Supported Method Parameters::
      # CSI::Plugins::DAOLDAP.connect(
      #   host: 'required host or IP',
      #   port: 'optional port (defaults to 636)',
      #   base: 'required ldap base to search from (e.g. dc=domain,dc=com)'
      #   encryption: 'optional parameter to protect communication in transit, :simple_tls OR :start_tls'
      #   auth_method: 'required ldap auth bind method, :simple, :sasl, OR :gss_spnego'
      #   username: 'required username (e.g. jake.hoopes@gmail.com)',
      #   password: 'optional (prompts if left blank)',
      # )

      public

      def self.connect(opts = {})
        host = opts[:host].to_s
        port = opts[:port].to_i
        base = opts[:base]
        encryption = opts[:encryption]
        auth_method = opts[:auth_method]

        username = opts[:username].to_s

        password = if opts[:password].nil?
                     CSI::Plugins::AuthenticationHelper.mask_password
                   else
                     opts[:password].to_s
                   end

        if encryption
          ldap_obj = Net::LDAP.new(
            host: host,
            port: port,
            base: base,
            encryption: encryption,
            auth: {
              method: auth_method,
              username: username,
              password: password
            }
          )
        else
          ldap_obj = Net::LDAP.new(
            host: host,
            port: port,
            base: base,
            auth: {
              method: auth_method,
              username: username,
              password: password
            }
          )
        end

        ldap_obj.bind

        return ldap_obj
      rescue => e
        return e.message
      end

      # Supported Method Parameters::
      # CSI::Plugins::DAOLDAP.get_employee_by_username(
      #   ldap_obj: 'required ldap_obj returned from #connect method',
      #   username: 'required username of employee to retrieve from LDAP server'
      # )

      public

      def self.get_employee_by_username(opts = {})
        ldap_obj = opts[:ldap_obj]
        username = opts[:username].to_s.scrub
        treebase = ldap_obj.base

        filter = Net::LDAP::Filter.eq('samaccountname', username)
        employee = ldap_obj.search(base: treebase, filter: filter)

        return employee
      rescue => e
        return e.message
      end

      # Supported Method Parameters::
      # CSI::Plugins::DAOLDAP.disconnect(
      #   ldap_obj: ldap_obj
      # )

      public

      def self.disconnect(opts = {})
        ldap_obj = opts[:ldap_obj]
        ldap_obj = nil
      rescue => e
        return e.message
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>

      public

      def self.authors
        authors = "AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        "

        authors
      end

      # Display Usage for this Module

      public

      def self.help
        puts "USAGE:
          ldap_obj = #{self}.connect(
            host: 'required host or IP',
            port: 'required port',
            base: 'required ldap base to search from (e.g. dc=domain,dc=com)',
            encryption: 'optional parameter to protect communication in transit, :simple_tls OR :start_tls',
            auth_method: 'required ldap auth bind method, :simple, :sasl, OR :gss_spnego'
            username: 'required username',
            password: 'optional (prompts if left blank)',
          )

          employee = #{self}.get_employee_by_username(
            ldap_obj: 'required ldap_obj returned from #connect method',
            username: 'required username of employee to retrieve from LDAP server'
          )
          puts employee[0][:dn]

          #{self}.disconnect(:ldap_obj => ldap_obj)

          #{self}.authors
        "
      end
    end
  end
end

# frozen_string_literal: true

require 'ipaddress'
require 'nokogiri'

module CSI
  module WWW
    # This plugin supports Checkip actions.
    module Checkip
      # Supported Method Parameters::
      # browser_obj = CSI::WWW::Checkip.open(
      #   browser_type: 'optional - :firefox|:chrome|:ie|:headless (Defaults to :firefox)',
      #   proxy: 'optional - scheme://proxy_host:port',
      #   with_tor: 'optional - boolean (defaults to false)'
      # )

      public_class_method def self.open(opts = {})
        browser_type = if opts[:browser_type].nil?
                         :firefox
                       else
                         opts[:browser_type]
                       end

        proxy = opts[:proxy].to_s unless opts[:proxy].nil?

        with_tor = if opts[:with_tor]
                     true
                   else
                     false
                   end

        if proxy
          if with_tor
            browser_obj = CSI::Plugins::TransparentBrowser.open(
              browser_type: browser_type,
              proxy: proxy,
              with_tor: with_tor
            )
          else
            browser_obj = CSI::Plugins::TransparentBrowser.open(
              browser_type: browser_type,
              proxy: proxy
            )
          end
        else
          browser_obj = CSI::Plugins::TransparentBrowser.open(
            browser_type: browser_type
          )
        end
        browser_obj.goto('http://checkip.amazonaws.com')
        public_ip_address = Nokogiri::HTML.parse(browser_obj.html).xpath('//pre').text.chomp
        puts "PUBLIC IP: #{public_ip_address}"

        return browser_obj
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # browser_obj = CSI::WWW::Checkip.close(
      #   browser_obj: 'required - browser_obj returned from #open method',
      # )

      public_class_method def self.close(opts = {})
        browser_obj = opts[:browser_obj]
        browser_obj = CSI::Plugins::TransparentBrowser.close(browser_obj: browser_obj)
      rescue => e
        raise e
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>

      public_class_method def self.authors
        authors = "AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        "

        authors
      end

      # Display Usage for this Module

      public_class_method def self.help
        puts %{USAGE:
          browser_obj = #{self}.open(
            browser_type: 'optional :firefox|:chrome|:ie|:headless (Defaults to :firefox)',
            proxy: 'optional - scheme://proxy_host:port',
            with_tor: 'optional - boolean (defaults to false)'
          )
          puts "browser_obj.public_methods"

          browser_obj = #{self}.close(
            browser_obj: 'required - browser_obj returned from #open method',
          )

          #{self}.authors
        }
      end
    end
  end
end

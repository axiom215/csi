# frozen_string_literal: true

module CSI
  module Plugins
    # This plugin provides useful social security number capabilities
    module SSN
      # Supported Method Parameters::
      # CSI::Plugins::SSN.generate(
      #   count: 'required - number of SSN numbers to generate'
      # )

      public_class_method def self.generate(opts = {})
        count = opts[:count].to_i
   
        # Based upon new SSN Randomization:
        # https://www.ssa.gov/employer/randomization.html
        ssn_result_arr = []
        (1..count).each do
          this_area = 
          this_area = sprintf("%0.3d", Random.rand(1..999))
          this_group = sprintf("%0.2d", Random.rand(1..99))
          this_serial = sprintf("%0.4d", Random.rand(1..9999))
          this_ssn = "#{this_area}-#{this_group}-#{this_serial}"
          ssn_result_arr.push(this_ssn)
        end

        ssn_result_arr
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
        puts "USAGE:
          #{self}.generate(
            count: 'required - number of SSN numbers to generate'
          )

          #{self}.authors
        "
      end
    end
  end
end

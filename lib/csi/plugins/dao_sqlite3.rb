# frozen_string_literal: true

require 'sqlite3'

module CSI
  module Plugins
    # This plugin is a data access object used for interacting w/ SQLite3
    # databases.
    module DAOSQLite3
      # Supported Method Parameters::
      # CSI::Plugins::DAOSQLite3.connect(
      #   dir_path: 'Required - Path of SQLite3 DB File'
      # )

      public_class_method def self.connect(opts = {})
        dir_path = opts[:dir_path]

        sqlite3_conn = SQLite3::Database.new(dir_path)
        # Be sure to enable foreign key support for each connection
        sql_enable_fk = 'PRAGMA foreign_keys = ?'
        res = sql_statement(
          sqlite3_conn: sqlite3_conn,
          prepared_statement: sql_enable_fk,
          statement_params: ['ON']
        )
        # TODO: better handling since sqlite3 gem always returns SQLite3::Database
        # whether DB exists or not
        unless sqlite3_conn.class == SQLite3::Database
          raise "
            Connection Error - class should be SQLite3::Database...received:
            sqlite3_conn = #{sqlite3_conn.inspect}
            sqlite3_conn.class = #{sqlite3_conn.class}
          "
        end

        return sqlite3_conn
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # validate_sqlite3_conn(
      #   sqlite3_conn: sqlite3_conn
      # )

      private_class_method def self.validate_sqlite3_conn(opts = {})
        sqlite3_conn = opts[:sqlite3_conn]
        unless sqlite3_conn.class == SQLite3::Database
          raise "Error: Invalid sqlite3_conn Object #{sqlite3_conn}"
        end
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::DAOSQLite3.sql_statement(
      #   sqlite3_conn: sqlite3_conn,
      #   prepared_statement: 'SELECT * FROM tn_users WHERE state = ?',
      #   statement_params: ['Active']
      # )

      public_class_method def self.sql_statement(opts = {})
        sqlite3_conn = opts[:sqlite3_conn]
        validate_sqlite3_conn(sqlite3_conn: sqlite3_conn)
        prepared_statement = opts[:prepared_statement] # Can also be leveraged for 'select * from user;'
        statement_params = opts[:statement_params] # << Array of Params
        unless statement_params.class == Array || statement_params.nil?
          raise "Error: :statement_params => #{statement_params.class}. Pass as an Array object"
        end

        if statement_params.nil?
          res = sqlite3_conn.execute(prepared_statement)
        else
          res = sqlite3_conn.execute(prepared_statement, statement_params)
        end
        return res
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::DAOSQLite3.disconnect(
      #   sqlite3_conn: sqlite3_conn
      # )

      public_class_method def self.disconnect(opts = {})
        sqlite3_conn = opts[:sqlite3_conn]
        validate_sqlite3_conn(sqlite3_conn: sqlite3_conn)

        sqlite3_conn.close
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
          sqlite3_conn = #{self}.connect(:dir_path => 'Required - Path of SQLite3 DB File')

          res = #{self}.sql_statement(
            :sqlite3_conn => sqlite3_conn,
            :prepared_statement => 'SELECT * FROM tn_users WHERE state = ?',
            :statement_params => ['Active']
          )

          #{self}.disconnect(:sqlite3_conn => sqlite3_conn)

          #{self}.authors
        "
      end
    end
  end
end

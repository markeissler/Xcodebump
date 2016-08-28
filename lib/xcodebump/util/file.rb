#
# lib/util/file.rb
#
# @author Mark Eissler
#
module Xcodebump
  module Util
    #
    # The File module is a mixin that encapsulates file utility functions.
    #
    # @author  Mark Eissler
    #
    module File
      require 'json'

      # Load the json config file located at the specified path.
      #
      # Once the config has been loaded and parsed, the resulting hash will
      # contains keys that have been converted to symbols.
      #
      # An example config file contents:
      # @example:
      #  {
      #    "appname": "Myapp",
      #    "version": "1.0.0"
      #  }
      #
      # @param path [String] path of json formatted config file
      #
      # @return [Hash] hash containing config options
      #
      def load_config(path)
        hash_with_symbols = {}
        expanded_path = ::File.expand_path(path)
        if ::File.file?(expanded_path)
          file = ::File.read(expanded_path)
          file_hash = ::JSON.parse(file)
          file_hash.keys.each do |key|
            hash_with_symbols[key.to_sym] = file_hash[key]
          end
        end

        return hash_with_symbols
      end

      # Quietly remove a file if it exists.
      #
      # @param path [String] path of file to delete
      #
      # @return [Bool] true if file removed sucessfully, otherwise false
      #
      def rm(path)
        expanded_path = ::File.expand_path(path)
        success = false
        if ::File.file?(expanded_path)
          success = (::File.delete(expanded_path) > 0)
        end

        return success
      end
    end
  end
end

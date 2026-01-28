# frozen_string_literal: true

module RailsSimpleParams
  class Validator
    class Required < Validator
      private

      def valid_value?
        return true unless options[:required]
        return false if value.nil?
        return false if value == ''
        return false if value.is_a?(Enumerable) && value.size.zero?

        true
      end

      def error_message
        "#{name} is required"
      end

      def exception_class
        MissingParameter
      end
    end
  end
end

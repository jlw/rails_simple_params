# frozen_string_literal: true

module RailsSimpleParams
  class Validator
    class Blank < Validator
      def valid_value?
        return false if parameter.options[:blank]

        case value
        when String
          (/\S/ === value)
        when Array, Hash, ActionController::Parameters
          !value.empty?
        else
          !value.nil?
        end
      end

      private

      def error_message
        "#{name} cannot be blank"
      end

      def exception_class
        EmptyParameter
      end
    end
  end
end

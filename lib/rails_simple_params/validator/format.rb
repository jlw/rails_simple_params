# frozen_string_literal: true

module RailsSimpleParams
  class Validator
    class Format < Validator
      TIME_TYPES = [Date, DateTime, Time].freeze

      # ConfigCheck only allows :format on String and time types, so after coercion the value is a
      # String, a Date/DateTime/Time (already parsed with the format), or nil (absent or null input).
      def valid_value?
        value.nil? || matches_time_types? || string_in_format?
      end

      private

      def error_message
        "#{name} must match format #{options[:format]}"
      end

      def exception_class
        InvalidFormat
      end

      def matches_time_types?
        TIME_TYPES.any? { |cls| value.is_a? cls }
      end

      def string_in_format?
        value.is_a?(String) && (value == '' || value =~ options[:format])
      end
    end
  end
end

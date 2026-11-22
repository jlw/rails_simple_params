# frozen_string_literal: true

module RailsSimpleParams
  class ConfigCheck
    class Base
      attr_reader :param, :options, :type

      def initialize(param:, type:, options: nil)
        @param = param
        @options = options
        @type = type
        configuration_validation
      end

      private

      def allowed_list
        return unless (allowed = options[:in])

        allowed = allowed.call if allowed.respond_to?(:call)
        allowed = [allowed.begin, allowed.end].compact if allowed.is_a?(Range)
        allowed
      end

      def configuration_validation
        raise NotImplementedError, "you must implement #configuration_validation in #{self.class.name}"
      end

      def raise_error(message)
        raise RailsSimpleParams::InvalidConfiguration.new(message, param:)
      end

      def reject(key, extra = nil)
        return unless options.key? key

        raise_error "#{type} param (#{param}) does not allow :#{key}#{extra}"
      end

      def validate_allowed_options(not_allowed, test_proc)
        return unless (allowed = allowed_list)

        raise_error ":in on #{param} is not a list" unless allowed.is_a?(Array) || allowed.is_a?(Range)

        return if allowed.all? { |n| test_proc.call(n) }

        raise_error "#{type} param (#{param}) does not allow #{not_allowed} :in options"
      end

      def validate_length(key)
        return unless options.key? key
        return if options[key].is_a? Integer

        raise_error ":#{key} on #{param} must be an Integer"
      end

      def validate_lengths
        validate_length :max_length
        validate_length :min_length
        return unless options.key?(:min_length) && options.key?(:max_length)
        return if options[:min_length] <= options[:max_length]

        raise_error ":max_length on #{param} cannot be smaller than :min_length"
      end

      def validate_limit(key)
        return unless options.key? key
        return if options[key].is_a? Numeric

        raise_error ":#{key} on #{param} must be a number"
      end

      def validate_limits
        validate_limit :max
        validate_limit :min
        return unless options.key?(:min) && options.key?(:max)
        return if options[:min] <= options[:max]

        raise_error ":max on #{param} cannot be smaller than :min"
      end
    end
  end
end

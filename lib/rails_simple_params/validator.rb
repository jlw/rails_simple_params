# frozen_string_literal: true

require 'forwardable'

module RailsSimpleParams
  class Validator
    extend Forwardable

    attr_reader :parameter

    def_delegators :parameter, :name, :options, :value

    PRESENCE_OPTIONS = %i[required blank].freeze # these run first
    VALUE_OPTIONS = %i[
      custom
      format
      in
      is
      max_length
      max
      min_length
      min
    ].freeze

    def initialize(parameter)
      @parameter = parameter
    end

    def validate!
      PRESENCE_OPTIONS.each { |key| run_validator(key) if options.key?(key) }
      return if value.nil?

      options.each_key do |key|
        next unless VALUE_OPTIONS.include?(key)

        run_validator(key)
      end
    end

    def valid!
      return if valid_value?

      raise exception_class.new(
        error_message,
        param: name,
        options: options
      )
    end

    private

    def run_validator(key)
      Validator.const_get(camelize(key)).new(parameter).valid!
    end

    def camelize(term)
      string = term.to_s
      string.split('_').collect(&:capitalize).join
    end

    def error_message
      nil
    end

    def exception_class
      InvalidParameter
    end

    def valid_value?
      # Should be overwritten in subclass
      false
    end
  end
end

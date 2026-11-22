# frozen_string_literal: true

module RailsSimpleParams
  class Parameter
    attr_accessor :name, :value, :options, :type

    def initialize(name:, value:, options: {}, type: nil)
      @name = name
      @value = value
      @options = options
      @type = type
    end

    def should_set_default?
      value.blank? && !options[:default].nil?
    end

    def set_default
      return unless should_set_default?

      self.value = options[:default].respond_to?(:call) ? options[:default].call : options[:default]
    end

    def transform
      return if value.nil?
      return unless options[:transform]

      self.value = options[:transform].to_proc.call(value)
    end

    def validate
      Validator.new(self).validate!
    end
  end
end

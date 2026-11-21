# frozen_string_literal: true

module RailsSimpleParams
  class InvalidParameter < StandardError
    attr_accessor :param, :options

    def initialize(message, param: nil, options: {})
      self.param = param
      self.options = options
      super(message)
    end

    def message
      return options[:message] if options.is_a?(Hash) && options.key?(:message)

      super
    end
  end

  class EmptyParameter < InvalidParameter; end
  class FileUpload < InvalidParameter; end
  class InvalidFormat < InvalidParameter; end
  class InvalidIdentity < InvalidParameter; end
  class InvalidOption < InvalidParameter; end
  class InvalidType < InvalidParameter; end
  class MissingParameter < InvalidParameter; end
  class OutOfRange < InvalidParameter; end
  class TooLarge < InvalidParameter; end
  class TooLong < InvalidParameter; end
  class TooShort < InvalidParameter; end
  class TooSmall < InvalidParameter; end

  class InvalidConfiguration < StandardError
    attr_accessor :param

    def initialize(message, param: nil)
      self.param = param
      super(message)
    end
  end
end

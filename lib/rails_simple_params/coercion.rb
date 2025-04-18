# frozen_string_literal: true

module RailsSimpleParams
  class Coercion
    PARAM_TYPE_MAPPING = {
      Integer => IntegerParam,
      Float => FloatParam,
      String => StringParam,
      Array => ArrayParam,
      Hash => HashParam,
      BigDecimal => BigDecimalParam,
      Date => TimeParam,
      DateTime => TimeParam,
      Time => TimeParam,
      TrueClass => BooleanParam,
      FalseClass => BooleanParam,
      boolean: BooleanParam
    }.freeze

    attr_reader :coercion, :param

    def initialize(param, type, options)
      @param = param
      @coercion = klass_for(type).new(param: param, options: options, type: type)
    end

    def coerce
      return nil if param.nil?

      coercion.coerce
    end

    private

    def klass_for(type)
      klass = PARAM_TYPE_MAPPING[type]
      return klass if klass

      raise TypeError
    end
  end
end

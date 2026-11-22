# frozen_string_literal: true

module RailsSimpleParams
  class Coercion
    class BigDecimalParam < Base
      DEFAULT_PRECISION = 14

      def coerce
        return nil if param == '' # e.g. from an empty field in an HTML form

        # Parse from a String (never via Float) so invalid input raises ArgumentError and no precision is lost.
        # Kernel#BigDecimal ignores its precision argument for Strings, so round to significant digits explicitly.
        value = BigDecimal(normalized_param).mult(1, options[:precision] || DEFAULT_PRECISION)
        raise ArgumentError unless value.finite?

        value
      end

      private

      def normalized_param
        param.is_a?(String) ? param.delete('$,').strip : param.to_s
      end
    end
  end
end

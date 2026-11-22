# frozen_string_literal: true

module RailsSimpleParams
  class Coercion
    class BooleanParam < Base
      FALSEY = /\A(false|f|no|n|0)\z/i
      TRUTHY = /\A(true|t|yes|y|1)\z/i

      def coerce
        return false if FALSEY === param.to_s
        return true if TRUTHY === param.to_s

        raise ArgumentError
      end
    end
  end
end

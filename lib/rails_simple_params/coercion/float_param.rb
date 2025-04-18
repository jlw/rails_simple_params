# frozen_string_literal: true

module RailsSimpleParams
  class Coercion
    class FloatParam < Base
      def coerce
        return nil if param == '' # e.g. from an empty field in an HTML form

        Float(param)
      end
    end
  end
end

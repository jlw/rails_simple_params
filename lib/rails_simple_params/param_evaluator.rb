# frozen_string_literal: true

module RailsSimpleParams
  class ParamEvaluator
    attr_accessor :params

    def initialize(params, context = nil)
      @params = params
      @context = context
    end

    def param!(name, type, options = {}, &) # rubocop:disable Metrics/MethodLength
      name = name.to_s unless name.is_a?(Integer)
      return unless evaluate?(name, options)

      parameter_name = @context ? "#{@context}[#{name}]" : name
      ConfigCheck.new(parameter_name, type, options)
      parameter = RailsSimpleParams::Parameter.new(
        name: parameter_name,
        value: coerce(parameter_name, params[name], type, options),
        type: type,
        options: options,
        &
      )

      parameter.set_default
      recurse_on_parameter(parameter, &) if block_given?
      parameter.transform
      parameter.validate

      # set params value
      params[name] = parameter.value
    end

    private

    def coerce(param_name, param, type, options = {})
      return nil if param.nil?

      reject_file_upload!(param_name, param, options)
      return param if begin
        param.is_a?(type)
      rescue StandardError
        false
      end

      Coercion.new(param, type, options).coerce
    rescue ArgumentError, TypeError
      raise InvalidType.new("'#{param}' is not a valid #{type}", param: param_name)
    end

    def evaluate?(name, options)
      params.include?(name) || !options[:default].nil? || options[:required]
    end

    def reject_file_upload!(param_name, param, options)
      return unless param.respond_to?(:original_filename) && param.respond_to?(:tempfile)

      raise FileUpload.new("#{param_name} does not allow file uploads", param: param_name, options: options)
    end

    def recurse(element, context, index = nil)
      raise InvalidConfiguration.new('no block given', param: element) unless block_given?

      yield(ParamEvaluator.new(element, context), index)
    end

    def recurse_on_parameter(parameter, &) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      return if parameter.value.nil?

      if parameter.type == Array
        parameter.value.each_with_index do |element, i|
          if element.is_a?(Hash) || element.is_a?(ActionController::Parameters)
            recurse(element, "#{parameter.name}[#{i}]", &)
          else
            # do not rely on the block's return value
            wrapper = { i => element }
            recurse(wrapper, parameter.name, i, &)
            parameter.value[i] = wrapper[i]
          end
        end
      else
        recurse(parameter.value, parameter.name, &)
      end
    end
  end
end

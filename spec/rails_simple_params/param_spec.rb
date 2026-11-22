require 'spec_helper'

class MyController < ActionController::Base
  include RailsSimpleParams

  def params; end
end

describe RailsSimpleParams do
  describe '.param!' do
    let(:controller) { MyController.new }

    it 'defines the method' do
      expect(controller).to respond_to(:param!)
    end

    describe 'options validation' do
      describe 'type' do
        it 'raises InvalidConfiguration on an unsupported type' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Symbol }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'Symbol is not a supported type for foo') do |error|
              expect(error.param).to eq 'foo'
            end
          )
        end

        it 'raises InvalidConfiguration on an unsupported type even when the param is absent but required' do
          allow(controller).to receive(:params).and_return({})
          expect { controller.param! :foo, :string, required: true }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, ':string is not a supported type for foo')
          )
        end

        it 'includes the full nested name for an unsupported type in a block' do
          allow(controller).to receive(:params).and_return({ 'book' => { 'title' => 'x' } })
          expect { controller.param!(:book, Hash) { |b| b.param! :title, Symbol } }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'Symbol is not a supported type for book[title]') do |error|
              expect(error.param).to eq 'book[title]'
            end
          )
        end
      end

      describe ':format' do
        it 'raises InvalidConfiguration on Integer' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Integer, format: /\w+/ }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'Integer param (foo) does not allow :format') do |error|
              expect(error.param).to eq 'foo'
            end
          )
        end

        it 'raises InvalidConfiguration on Float' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Float, format: /\w+/ }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'Float param (foo) does not allow :format') do |error|
              expect(error.param).to eq 'foo'
            end
          )
        end

        it 'raises InvalidConfiguration on :boolean' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, :boolean, format: /\w+/ }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'boolean param (foo) does not allow :format') do |error|
              expect(error.param).to eq 'foo'
            end
          )
        end

        it 'raises InvalidConfiguration on TrueClass' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, TrueClass, format: /\w+/ }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'TrueClass param (foo) does not allow :format') do |error|
              expect(error.param).to eq 'foo'
            end
          )
        end

        it 'raises InvalidConfiguration on FalseClass' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, FalseClass, format: /\w+/ }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'FalseClass param (foo) does not allow :format') do |error|
              expect(error.param).to eq 'foo'
            end
          )
        end

        it 'raises InvalidConfiguration on Array' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Array, format: /\w+/ }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'Array param (foo) does not allow :format') do |error|
              expect(error.param).to eq 'foo'
            end
          )
        end

        it 'raises InvalidConfiguration on Hash' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Hash, format: /\w+/ }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'Hash param (foo) does not allow :format') do |error|
              expect(error.param).to eq 'foo'
            end
          )
        end

        it 'raises InvalidConfiguration on BigDecimal' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, BigDecimal, format: /\w+/ }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'BigDecimal param (foo) does not allow :format') do |error|
              expect(error.param).to eq 'foo'
            end
          )
        end
      end

      describe ':in' do
        it 'raises InvalidConfiguration on String with non-String options' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, String, in: (5..20) }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'String param (foo) does not allow non-String :in options')
          )
        end

        it 'raises InvalidConfiguration on Integer with non-Integer options' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Integer, in: ['apple', 42] }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration,
                        'Integer param (foo) does not allow non-Integer :in options')
          )
        end

        it 'raises InvalidConfiguration on Float with non-Float options' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Float, in: ['apple', 42.0] }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'Float param (foo) does not allow non-Numeric :in options')
          )
        end

        it 'raises InvalidConfiguration on :boolean with non-boolean options' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, :boolean, in: %w[a b] }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'boolean param (foo) does not allow :in')
          )
        end

        it 'raises InvalidConfiguration on TrueClass' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, TrueClass, in: (5..20) }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'TrueClass param (foo) does not allow :in')
          )
        end

        it 'raises InvalidConfiguration on FalseClass' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, FalseClass, in: ['a', 1] }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'FalseClass param (foo) does not allow :in')
          )
        end

        it 'raises InvalidConfiguration on Array' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Array, in: %w[a b] }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'Array param (foo) does not allow :in')
          )
        end

        it 'raises InvalidConfiguration on Hash' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Hash, in: (5..20) }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'Hash param (foo) does not allow :in')
          )
        end

        it 'raises InvalidConfiguration on BigDecimal with non-BigDecimal values' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, BigDecimal, in: [7, 42] }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'BigDecimal param (foo) does not allow :in (use :min/:max)')
          )
        end
      end

      describe ':max' do
        it 'raises InvalidConfiguration on non-numeric option' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Integer, max: 'abc' }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, ':max on foo must be a number')
          )
        end

        it 'raises InvalidConfiguration when smaller than :min' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Integer, max: 2, min: 4 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, ':max on foo must be larger than :min')
          )
        end

        it 'raises InvalidConfiguration on String' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, String, max: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'String param (foo) does not allow :max')
          )
        end

        it 'raises InvalidConfiguration on :boolean' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, :boolean, max: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'boolean param (foo) does not allow :max')
          )
        end

        it 'raises InvalidConfiguration on TrueClass' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, TrueClass, max: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'TrueClass param (foo) does not allow :max')
          )
        end

        it 'raises InvalidConfiguration on FalseClass' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, FalseClass, max: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'FalseClass param (foo) does not allow :max')
          )
        end

        it 'raises InvalidConfiguration on Array' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Array, max: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'Array param (foo) does not allow :max')
          )
        end

        it 'raises InvalidConfiguration on Hash' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Hash, max: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'Hash param (foo) does not allow :max')
          )
        end
      end

      describe ':max_length' do
        it 'raises InvalidConfiguration on non-Integer option' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, String, max_length: 42.2 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, ':max_length on foo must be an Integer')
          )
        end

        it 'raises InvalidConfiguration when smaller than :min_length' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, String, max_length: 2, min_length: 4 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, ':max_length on foo must be larger than :min_length')
          )
        end

        it 'raises InvalidConfiguration on Integer' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Integer, max_length: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'Integer param (foo) does not allow :max_length')
          )
        end

        it 'raises InvalidConfiguration on Float' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Float, max_length: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'Float param (foo) does not allow :max_length')
          )
        end

        it 'raises InvalidConfiguration on :boolean' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, :boolean, max_length: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'boolean param (foo) does not allow :max_length')
          )
        end

        it 'raises InvalidConfiguration on TrueClass' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, TrueClass, max_length: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'TrueClass param (foo) does not allow :max_length')
          )
        end

        it 'raises InvalidConfiguration on FalseClass' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, FalseClass, max_length: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'FalseClass param (foo) does not allow :max_length')
          )
        end

        it 'raises InvalidConfiguration on Array' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Array, max_length: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'Array param (foo) does not allow :max_length')
          )
        end

        it 'raises InvalidConfiguration on Hash' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Hash, max_length: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'Hash param (foo) does not allow :max_length')
          )
        end

        it 'raises InvalidConfiguration on BigDecimal' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, BigDecimal, max_length: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'BigDecimal param (foo) does not allow :max_length')
          )
        end
      end

      describe ':min' do
        it 'raises InvalidConfiguration on non-numeric option' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Integer, min: 'abc' }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, ':min on foo must be a number')
          )
        end

        it 'raises InvalidConfiguration on String' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, String, min: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'String param (foo) does not allow :min')
          )
        end

        it 'raises InvalidConfiguration on :boolean' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, :boolean, min: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'boolean param (foo) does not allow :min')
          )
        end

        it 'raises InvalidConfiguration on TrueClass' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, TrueClass, min: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'TrueClass param (foo) does not allow :min')
          )
        end

        it 'raises InvalidConfiguration on FalseClass' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, FalseClass, min: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'FalseClass param (foo) does not allow :min')
          )
        end

        it 'raises InvalidConfiguration on Array' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Array, min: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'Array param (foo) does not allow :min')
          )
        end

        it 'raises InvalidConfiguration on Hash' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Hash, min: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'Hash param (foo) does not allow :min')
          )
        end
      end

      describe ':min_length' do
        it 'raises InvalidConfiguration on non-Integer option' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, String, min_length: 42.2 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, ':min_length on foo must be an Integer')
          )
        end

        it 'raises InvalidConfiguration on Integer' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Integer, min_length: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'Integer param (foo) does not allow :min_length')
          )
        end

        it 'raises InvalidConfiguration on Float' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Float, min_length: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'Float param (foo) does not allow :min_length')
          )
        end

        it 'raises InvalidConfiguration on :boolean' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, :boolean, min_length: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'boolean param (foo) does not allow :min_length')
          )
        end

        it 'raises InvalidConfiguration on TrueClass' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, TrueClass, min_length: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'TrueClass param (foo) does not allow :min_length')
          )
        end

        it 'raises InvalidConfiguration on FalseClass' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, FalseClass, min_length: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'FalseClass param (foo) does not allow :min_length')
          )
        end

        it 'raises InvalidConfiguration on Array' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Array, min_length: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'Array param (foo) does not allow :min_length')
          )
        end

        it 'raises InvalidConfiguration on Hash' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, Hash, min_length: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'Hash param (foo) does not allow :min_length')
          )
        end

        it 'raises InvalidConfiguration on BigDecimal' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          expect { controller.param! :foo, BigDecimal, min_length: 42 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration, 'BigDecimal param (foo) does not allow :min_length')
          )
        end
      end
    end

    describe 'transform' do
      context 'with a method' do
        it 'transforms the value' do
          allow(controller).to receive(:params).and_return({ 'word' => 'foo' })
          controller.param! :word, String, transform: :upcase
          expect(controller.params['word']).to eq 'FOO'
        end

        it 'transforms default value' do
          allow(controller).to receive(:params).and_return({})
          controller.param! :word, String, default: 'foo', transform: :upcase
          expect(controller.params['word']).to eq 'FOO'
        end
      end

      context 'with a block' do
        it 'transforms the value' do
          allow(controller).to receive(:params).and_return({ 'word' => 'FOO' })
          controller.param! :word, String, transform: ->(n) { n.downcase } # rubocop:disable Style/SymbolProc
          expect(controller.params['word']).to eq 'foo'
        end

        it 'transforms default value' do
          allow(controller).to receive(:params).and_return({})
          controller.param! :word, String, default: 'foo', transform: ->(n) { n.upcase } # rubocop:disable Style/SymbolProc
          expect(controller.params['word']).to eq 'FOO'
        end

        it 'transforms falsey value' do
          allow(controller).to receive(:params).and_return({ 'foo' => '0' })
          controller.param! :foo, :boolean, transform: ->(n) { n ? 'bar' : 'no bar' }
          expect(controller.params['foo']).to eq 'no bar'
        end
      end

      context 'when param is required & not present' do
        it "doesn't transform the value" do
          allow(controller).to receive(:params).and_return({ 'foo' => nil })
          expect { controller.param! :foo, String, required: true, transform: :upcase }.to(
            raise_error(RailsSimpleParams::MissingParameter, 'foo is required') do |error|
              expect(error.param).to eq 'foo'
            end
          )
        end
      end

      context 'when param is optional & not present' do
        it "doesn't transform the value" do
          allow(controller).to receive(:params).and_return({})
          expect { controller.param! :foo, String, transform: :upcase }.not_to raise_error
        end
      end
    end

    describe 'default' do
      context 'with a value' do
        it 'defaults to the value' do
          allow(controller).to receive(:params).and_return({})
          controller.param! :word, String, default: 'foo'
          expect(controller.params['word']).to eq 'foo'
        end

        it 'does not default to the value if value already provided' do
          allow(controller).to receive(:params).and_return({ 'word' => 'bar' })
          controller.param! :word, String, default: 'foo'
          expect(controller.params['word']).to eq 'bar'
        end
      end

      context 'with a block' do
        it 'defaults to the block value' do
          allow(controller).to receive(:params).and_return({})
          controller.param! :foo, :boolean, default: -> { false }
          expect(controller.params['foo']).to eq false
        end

        it 'does not default to the value if value already provided' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'bar' })
          controller.param! :foo, String, default: -> { 'not bar' }
          expect(controller.params['foo']).to eq 'bar'
        end
      end
    end

    describe 'file uploads' do
      let(:upload) { ActionDispatch::Http::UploadedFile.new(tempfile: Tempfile.new, filename: 'a.txt') }

      [String, Integer, Float, BigDecimal, :boolean, Array, Hash, Date, Time, DateTime].each do |type|
        it "raises FileUpload when a #{type} param receives an uploaded file" do
          allow(controller).to receive(:params).and_return({ 'foo' => upload })
          expect { controller.param! :foo, type }.to(
            raise_error(RailsSimpleParams::FileUpload, 'foo does not allow file uploads') do |error|
              expect(error.param).to eq 'foo'
            end
          )
        end
      end

      it 'uses the custom :message option' do
        allow(controller).to receive(:params).and_return({ 'foo' => upload })
        expect { controller.param! :foo, String, message: 'no files' }.to(
          raise_error(RailsSimpleParams::FileUpload, 'no files')
        )
      end
    end

    describe 'coerce' do
      describe 'String' do
        it 'will convert to String' do
          allow(controller).to receive(:params).and_return({ 'foo' => :bar })
          controller.param! :foo, String
          expect(controller.params['foo']).to eq 'bar'
        end
      end

      describe 'Integer' do
        it 'will convert to Integer if the value is valid' do
          allow(controller).to receive(:params).and_return({ 'foo' => '42' })
          controller.param! :foo, Integer
          expect(controller.params['foo']).to eq 42
        end

        it 'will allow a nil value (e.g. from an empty field in an HTML form)' do
          allow(controller).to receive(:params).and_return({ 'foo' => '' })
          controller.param! :foo, Integer
          expect(controller.params['foo']).to be nil
        end

        it 'will raise InvalidType if the value is not valid' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'notInteger' })
          expect { controller.param! :foo, Integer }.to(
            raise_error(RailsSimpleParams::InvalidType, "'notInteger' is not a valid Integer") do |error|
              expect(error.param).to eq 'foo'
            end
          )
        end

        it 'will raise InvalidType if the value is a boolean' do
          allow(controller).to receive(:params).and_return({ 'foo' => true })
          expect { controller.param! :foo, Integer }.to(
            raise_error(RailsSimpleParams::InvalidType, "'true' is not a valid Integer") do |error|
              expect(error.param).to eq 'foo'
            end
          )
        end
      end

      describe 'Float' do
        it 'will convert to Float' do
          allow(controller).to receive(:params).and_return({ 'foo' => '42.22' })
          controller.param! :foo, Float
          expect(controller.params['foo']).to eq 42.22
        end

        it 'will allow a nil value (e.g. from an empty field in an HTML form)' do
          allow(controller).to receive(:params).and_return({ 'foo' => '' })
          controller.param! :foo, Float
          expect(controller.params['foo']).to be nil
        end

        it 'will raise InvalidType if the value is not valid' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'notFloat' })
          expect { controller.param! :foo, Float }.to(
            raise_error(RailsSimpleParams::InvalidType, "'notFloat' is not a valid Float") do |error|
              expect(error.param).to eq 'foo'
            end
          )
        end

        it 'will raise InvalidType if the value is a boolean' do
          allow(controller).to receive(:params).and_return({ 'foo' => true })
          expect { controller.param! :foo, Float }.to(
            raise_error(RailsSimpleParams::InvalidType, "'true' is not a valid Float") do |error|
              expect(error.param).to eq 'foo'
            end
          )
        end
      end

      describe 'Array' do
        it 'will convert to Array' do
          allow(controller).to receive(:params).and_return({ 'foo' => '2,3,4,5' })
          controller.param! :foo, Array
          expect(controller.params['foo']).to eq %w[2 3 4 5]
        end

        it 'will raise InvalidType if the value is a boolean' do
          allow(controller).to receive(:params).and_return({ 'foo' => true })
          expect { controller.param! :foo, Array }.to(
            raise_error(RailsSimpleParams::InvalidType, "'true' is not a valid Array") do |error|
              expect(error.param).to eq 'foo'
            end
          )
        end
      end

      describe 'Hash' do
        it 'will convert to Hash' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'key1:foo,key2:bar' })
          controller.param! :foo, Hash
          expect(controller.params['foo']).to eq({ 'key1' => 'foo', 'key2' => 'bar' })
        end

        it 'will raise InvalidType if the value is a boolean' do
          allow(controller).to receive(:params).and_return({ 'foo' => true })
          expect { controller.param! :foo, Hash }.to(
            raise_error(RailsSimpleParams::InvalidType, "'true' is not a valid Hash") do |error|
              expect(error.param).to eq 'foo'
            end
          )
        end
      end

      describe 'Date' do
        context 'default condition' do
          it 'will convert to DateTime' do
            allow(controller).to receive(:params).and_return({ 'foo' => '1984-01-10' })
            controller.param! :foo, Date
            expect(controller.params['foo']).to eq Date.new(1984, 1, 10)
          end

          it 'will raise InvalidType if the value is not valid' do
            allow(controller).to receive(:params).and_return({ 'foo' => 'notDate' })
            expect { controller.param! :foo, Date }.to(
              raise_error(RailsSimpleParams::InvalidType, "'notDate' is not a valid Date") do |error|
                expect(error.param).to eq 'foo'
              end
            )
          end
        end

        context 'with format' do
          it 'will convert to DateTime' do
            allow(controller).to receive(:params).and_return({ 'foo' => '1984-01-10T12:25:00.000+02:00' })
            controller.param! :foo, Date, format: '%F'
            expect(controller.params['foo']).to eq Date.new(1984, 1, 10)
          end

          it 'will raise InvalidType if the value is not valid' do
            allow(controller).to receive(:params).and_return({ 'foo' => 'notDate' })
            expect { controller.param! :foo, DateTime, format: '%F' }.to(
              raise_error(RailsSimpleParams::InvalidType, "'notDate' is not a valid DateTime") do |error|
                expect(error.param).to eq 'foo'
              end
            )
          end

          it 'will raise InvalidType if the format is not valid' do
            allow(controller).to receive(:params).and_return({ 'foo' => '1984-01-10' })
            expect { controller.param! :foo, DateTime, format: '%x' }.to(
              raise_error(RailsSimpleParams::InvalidType, "'1984-01-10' is not a valid DateTime") do |error|
                expect(error.param).to eq 'foo'
              end
            )
          end
        end
      end

      describe 'Time' do
        context 'default condition' do
          it 'will convert to Time' do
            allow(controller).to receive(:params).and_return({ 'foo' => '2014-08-07T12:25:00.000+02:00' })
            controller.param! :foo, Time
            expect(controller.params['foo']).to eq Time.new(2014, 8, 7, 12, 25, 0, 7200)
          end

          it 'will raise InvalidType if the value is not valid' do
            allow(controller).to receive(:params).and_return({ 'foo' => 'notTime' })
            expect { controller.param! :foo, Time }.to(
              raise_error(RailsSimpleParams::InvalidType, "'notTime' is not a valid Time") do |error|
                expect(error.param).to eq 'foo'
              end
            )
          end
        end

        context 'with format' do
          it 'will convert to Time' do
            allow(controller).to receive(:params).and_return({ 'foo' => '2014-08-07T12:25:00.000+02:00' })
            controller.param! :foo, Time, format: '%F'
            expect(controller.params['foo']).to eq Time.new(2014, 8, 7)
          end

          it 'will raise InvalidType if the value is not valid' do
            allow(controller).to receive(:params).and_return({ 'foo' => 'notDate' })
            expect { controller.param! :foo, Time, format: '%F' }.to(
              raise_error(RailsSimpleParams::InvalidType, "'notDate' is not a valid Time") do |error|
                expect(error.param).to eq 'foo'
              end
            )
          end

          it 'will raise InvalidType if the format is not valid' do
            allow(controller).to receive(:params).and_return({ 'foo' => '2014-08-07T12:25:00.000+02:00' })
            expect { controller.param! :foo, Time, format: '%x' }.to(
              raise_error(RailsSimpleParams::InvalidType,
                          "'2014-08-07T12:25:00.000+02:00' is not a valid Time") do |error|
                expect(error.param).to eq 'foo'
              end
            )
          end
        end
      end

      describe 'DateTime' do
        context 'default condition' do
          it 'will convert to DateTime' do
            allow(controller).to receive(:params).and_return({ 'foo' => '2014-08-07T12:25:00.000+02:00' })
            controller.param! :foo, DateTime
            expect(controller.params['foo']).to eq DateTime.new(2014, 8, 7, 12, 25, 0, '+2')
          end

          it 'will raise InvalidType if the value is not valid' do
            allow(controller).to receive(:params).and_return({ 'foo' => 'notTime' })
            expect { controller.param! :foo, DateTime }.to(
              raise_error(RailsSimpleParams::InvalidType, "'notTime' is not a valid DateTime") do |error|
                expect(error.param).to eq 'foo'
              end
            )
          end
        end

        context 'with format' do
          it 'will convert to DateTime' do
            allow(controller).to receive(:params).and_return({ 'foo' => '2014-08-07T12:25:00.000+02:00' })
            controller.param! :foo, DateTime, format: '%F'
            expect(controller.params['foo']).to eq DateTime.new(2014, 8, 7)
          end

          it 'will raise InvalidType if the value is not valid' do
            allow(controller).to receive(:params).and_return({ 'foo' => 'notDate' })
            expect { controller.param! :foo, DateTime, format: '%F' }.to(
              raise_error(RailsSimpleParams::InvalidType, "'notDate' is not a valid DateTime") do |error|
                expect(error.param).to eq 'foo'
              end
            )
          end

          it 'will raise InvalidType if the format is not valid' do
            allow(controller).to receive(:params).and_return({ 'foo' => '2014-08-07T12:25:00.000+02:00' })
            expect { controller.param! :foo, DateTime, format: '%x' }.to(
              raise_error(RailsSimpleParams::InvalidType,
                          "'2014-08-07T12:25:00.000+02:00' is not a valid DateTime") do |error|
                expect(error.param).to eq 'foo'
              end
            )
          end
        end
      end

      describe 'BigDecimals' do
        it 'converts to BigDecimal using default precision' do
          allow(controller).to receive(:params).and_return({ 'foo' => 12_345.67890123456 })
          controller.param! :foo, BigDecimal
          expect(controller.params['foo']).to eq 12_345.678901235
        end

        it 'converts to BigDecimal using precision option' do
          allow(controller).to receive(:params).and_return({ 'foo' => 12_345.6789 })
          controller.param! :foo, BigDecimal, precision: 6
          expect(controller.params['foo']).to eq 12_345.7
        end

        it 'converts formatted currency string to big decimal' do
          allow(controller).to receive(:params).and_return({ 'foo' => '$100,000' })
          controller.param! :foo, BigDecimal
          expect(controller.params['foo']).to eq 100_000.0
        end

        it 'raises InvalidType on a non-numeric string' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'abc' })
          expect { controller.param! :foo, BigDecimal }.to(
            raise_error(RailsSimpleParams::InvalidType, "'abc' is not a valid BigDecimal") do |error|
              expect(error.param).to eq 'foo'
            end
          )
        end

        it 'raises InvalidType on a string with trailing garbage' do
          allow(controller).to receive(:params).and_return({ 'foo' => '12abc' })
          expect { controller.param! :foo, BigDecimal }.to raise_error(RailsSimpleParams::InvalidType)
        end

        it 'keeps full precision when the precision option exceeds what a Float can hold' do
          allow(controller).to receive(:params).and_return({ 'foo' => '12345678901234567.89' })
          controller.param! :foo, BigDecimal, precision: 20
          expect(controller.params['foo']).to eq BigDecimal('12345678901234567.89')
        end
      end

      describe 'booleans' do
        it 'converts 1/0' do
          allow(controller).to receive(:params).and_return({ 'foo' => '1' })
          controller.param! :foo, TrueClass
          expect(controller.params['foo']).to eq true

          allow(controller).to receive(:params).and_return({ 'foo' => '0' })
          controller.param! :foo, TrueClass
          expect(controller.params['foo']).to eq false
        end

        it 'converts true/false' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'true' })
          controller.param! :foo, TrueClass
          expect(controller.params['foo']).to eq true

          allow(controller).to receive(:params).and_return({ 'foo' => 'false' })
          controller.param! :foo, TrueClass
          expect(controller.params['foo']).to eq false
        end

        it 'converts t/f' do
          allow(controller).to receive(:params).and_return({ 'foo' => 't' })
          controller.param! :foo, TrueClass
          expect(controller.params['foo']).to eq true

          allow(controller).to receive(:params).and_return({ 'foo' => 'f' })
          controller.param! :foo, TrueClass
          expect(controller.params['foo']).to eq false
        end

        it 'converts yes/no' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'yes' })
          controller.param! :foo, TrueClass
          expect(controller.params['foo']).to eq true

          allow(controller).to receive(:params).and_return({ 'foo' => 'no' })
          controller.param! :foo, TrueClass
          expect(controller.params['foo']).to eq false
        end

        it 'converts y/n' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'y' })
          controller.param! :foo, TrueClass
          expect(controller.params['foo']).to eq true

          allow(controller).to receive(:params).and_return({ 'foo' => 'n' })
          controller.param! :foo, TrueClass
          expect(controller.params['foo']).to eq false
        end

        it 'return InvalidType if value not boolean' do
          allow(controller).to receive(:params).and_return({ 'foo' => '1111' })
          expect { controller.param! :foo, :boolean }.to(
            raise_error(RailsSimpleParams::InvalidType, "'1111' is not a valid boolean") do |error|
              expect(error.param).to eq 'foo'
            end
          )
        end

        it 'set default boolean' do
          allow(controller).to receive(:params).and_return({})
          controller.param! :foo, :boolean, default: false
          expect(controller.params['foo']).to eq false
        end
      end

      describe 'Arrays' do
        it 'will handle nil' do
          allow(controller).to receive(:params).and_return({ 'foo' => nil })
          expect { controller.param! :foo, Array }.not_to raise_error
        end
      end
    end

    # rubocop:disable Style/MultilineBlockChain
    describe 'validating nested hash' do
      it 'typecasts nested attributes' do
        allow(controller).to receive(:params).and_return({ 'foo' => { 'bar' => 1, 'baz' => 2 } })
        controller.param! :foo, Hash do |p|
          p.param! :bar, BigDecimal
          p.param! :baz, Float
        end
        expect(controller.params['foo']['bar']).to be_instance_of BigDecimal
        expect(controller.params['foo']['baz']).to be_instance_of Float
      end

      it 'does not raise exception if hash is not required but nested attributes are, and no hash is provided' do
        allow(controller).to receive(:params).and_return(foo: nil)
        controller.param! :foo, Hash do |p|
          p.param! :bar, BigDecimal, required: true
          p.param! :baz, Float, required: true
        end
        expect(controller.params['foo']).to be_nil
      end

      it 'raises exception if hash is required, nested attributes are not required, and no hash is provided' do
        allow(controller).to receive(:params).and_return(foo: nil)

        expect do
          controller.param! :foo, Hash, required: true do |p|
            p.param! :bar, BigDecimal
            p.param! :baz, Float
          end
        end.to raise_error(RailsSimpleParams::MissingParameter, 'foo is required') do |error|
          expect(error.param).to eq 'foo'
        end
      end

      it 'raises exception if hash is not required but nested attributes are, and hash has missing attributes' do
        allow(controller).to receive(:params).and_return({ 'foo' => { 'bar' => 1, 'baz' => nil } })
        expect do
          controller.param! :foo, Hash do |p|
            p.param! :bar, BigDecimal, required: true
            p.param! :baz, Float, required: true
          end
        end.to raise_error(RailsSimpleParams::MissingParameter, 'foo[baz] is required') do |error|
          expect(error.param).to eq 'foo[baz]'
        end
      end
    end

    describe 'validating arrays' do
      it 'typecasts array of primitive elements' do
        allow(controller).to receive(:params).and_return({ 'array' => %w[1 2] })
        controller.param! :array, Array do |a, i|
          a.param! i, Integer, required: true
        end
        expect(controller.params['array'][0]).to be_a Integer
        expect(controller.params['array'][1]).to be_a Integer
      end

      it 'validates array of hashes' do
        params = { 'array' => [{ 'object' => { 'num' => '1', 'float' => '1.5' } },
                               { 'object' => { 'num' => '2', 'float' => '2.3' } }] }
        allow(controller).to receive(:params).and_return(params)
        controller.param! :array, Array do |a|
          a.param! :object, Hash do |h|
            h.param! :num, Integer, required: true
            h.param! :float, Float, required: true
          end
        end
        expect(controller.params['array'][0]['object']['num']).to be_a Integer
        expect(controller.params['array'][0]['object']['float']).to be_instance_of Float
        expect(controller.params['array'][1]['object']['num']).to be_a Integer
        expect(controller.params['array'][1]['object']['float']).to be_instance_of Float
      end

      it 'validates an array of arrays' do
        params = { 'array' => [%w[1 2], %w[3 4]] }
        allow(controller).to receive(:params).and_return(params)
        controller.param! :array, Array do |a, i|
          a.param! i, Array do |b, e|
            b.param! e, Integer, required: true
          end
        end
        expect(controller.params['array'][0][0]).to be_a Integer
        expect(controller.params['array'][0][1]).to be_a Integer
        expect(controller.params['array'][1][0]).to be_a Integer
        expect(controller.params['array'][1][1]).to be_a Integer
      end

      it 'raises exception when primitive element missing' do
        allow(controller).to receive(:params).and_return({ 'array' => ['1', nil] })
        expect do
          controller.param! :array, Array do |a, i|
            a.param! i, Integer, required: true
          end
        end.to raise_error(RailsSimpleParams::MissingParameter, 'array[1] is required') do |error|
          expect(error.param).to eq 'array[1]'
        end
      end

      it 'raises exception when nested hash element missing' do
        params = { 'array' => [{ 'object' => { 'num' => '1', 'float' => nil } },
                               { 'object' => { 'num' => '2', 'float' => '2.3' } }] }
        allow(controller).to receive(:params).and_return(params)
        expect do
          controller.param! :array, Array do |a|
            a.param! :object, Hash do |h|
              h.param! :num, Integer, required: true
              h.param! :float, Float, required: true
            end
          end
        end.to raise_error(RailsSimpleParams::MissingParameter,
                           'array[0][object][float] is required') do |error|
          expect(error.param).to eq 'array[0][object][float]'
        end
      end

      it 'raises exception when nested array element missing' do
        params = { 'array' => [%w[1 2], ['3', nil]] }
        allow(controller).to receive(:params).and_return(params)
        expect do
          controller.param! :array, Array do |a, i|
            a.param! i, Array do |b, e|
              b.param! e, Integer, required: true
            end
          end
        end.to raise_error(RailsSimpleParams::MissingParameter, 'array[1][1] is required') do |error|
          expect(error.param).to eq 'array[1][1]'
        end
      end

      it 'does not raise exception if array is not required but nested attributes are, and no array is provided' do
        allow(controller).to receive(:params).and_return(foo: nil)
        controller.param! :foo, Array do |p|
          p.param! :bar, BigDecimal, required: true
          p.param! :baz, Float, required: true
        end
        expect(controller.params['foo']).to be_nil
      end

      it 'raises exception if array is required, nested attributes are not required, and no array is provided' do
        allow(controller).to receive(:params).and_return(foo: nil)
        expect do
          controller.param! :foo, Array, required: true do |p|
            p.param! :bar, BigDecimal
            p.param! :baz, Float
          end
        end.to raise_error(RailsSimpleParams::MissingParameter, 'foo is required') do |error|
          expect(error.param).to eq 'foo'
        end
      end
    end
    # rubocop:enable Style/MultilineBlockChain

    describe 'validation' do
      describe 'required parameter' do
        it 'succeeds' do
          allow(controller).to receive(:params).and_return({ 'price' => '50' })
          expect { controller.param! :price, Integer, required: true }.to_not raise_error
        end

        it 'raises' do
          allow(controller).to receive(:params).and_return({})
          expect { controller.param! :price, Integer, required: true }.to(
            raise_error(RailsSimpleParams::MissingParameter, 'price is required') do |error|
              expect(error.param).to eq 'price'
            end
          )
        end

        it 'raises on a nil value (e.g. from an empty field in an HTML form)' do
          allow(controller).to receive(:params).and_return({ 'foo' => '' })
          expect { controller.param! :foo, BigDecimal, required: true }.to(
            raise_error(RailsSimpleParams::MissingParameter, 'foo is required')
          )
        end

        it 'raises custom message' do
          allow(controller).to receive(:params).and_return({})
          expect { controller.param! :price, Integer, required: true, message: 'No price specified' }.to(
            raise_error(RailsSimpleParams::MissingParameter, 'No price specified') do |error|
              expect(error.param).to eq 'price'
            end
          )
        end
      end

      describe 'blank parameter' do
        it 'succeeds with not empty String' do
          allow(controller).to receive(:params).and_return({ 'price' => '50' })
          expect { controller.param! :price, String, blank: false }.to_not raise_error
        end

        it 'raises with empty String' do
          allow(controller).to receive(:params).and_return({ 'price' => '' })
          expect { controller.param! :price, String, blank: false }.to(
            raise_error(RailsSimpleParams::EmptyParameter, 'price cannot be blank') do |error|
              expect(error.param).to eq 'price'
            end
          )
        end

        it 'succeeds with not empty Hash' do
          allow(controller).to receive(:params).and_return({ 'hash' => { 'price' => '50' } })
          expect { controller.param! :hash, Hash, blank: false }.to_not raise_error
        end

        it 'raises with empty Hash' do
          allow(controller).to receive(:params).and_return({ 'hash' => {} })
          expect { controller.param! :hash, Hash, blank: false }.to(
            raise_error(RailsSimpleParams::EmptyParameter, 'hash cannot be blank') do |error|
              expect(error.param).to eq 'hash'
            end
          )
        end

        it 'succeeds with not empty Array' do
          allow(controller).to receive(:params).and_return({ 'array' => [50] })
          expect { controller.param! :array, Array, blank: false }.to_not raise_error
        end

        it 'raises with empty Array' do
          allow(controller).to receive(:params).and_return({ 'array' => [] })
          expect { controller.param! :array, Array, blank: false }.to(
            raise_error(RailsSimpleParams::EmptyParameter, 'array cannot be blank') do |error|
              expect(error.param).to eq 'array'
            end
          )
        end

        it 'succeeds with not empty ActiveController::Parameters' do
          allow(controller)
            .to receive(:params).and_return({ 'hash' => ActionController::Parameters.new({ 'price' => '50' }) })
          expect { controller.param! :hash, Hash, blank: false }.to_not raise_error
        end

        it 'raises with empty ActiveController::Parameters' do
          allow(controller).to receive(:params).and_return({ 'hash' => ActionController::Parameters.new })
          expect { controller.param! :hash, Hash, blank: false }.to(
            raise_error(RailsSimpleParams::EmptyParameter, 'hash cannot be blank') do |error|
              expect(error.param).to eq 'hash'
            end
          )
        end

        it 'succeeds with a non-blank String when blank: true' do
          allow(controller).to receive(:params).and_return({ 'price' => 'foo' })
          expect { controller.param! :price, String, blank: true }.to_not raise_error
          expect(controller.params['price']).to eq 'foo'
        end

        it 'succeeds with a blank String when blank: true' do
          allow(controller).to receive(:params).and_return({ 'price' => '' })
          expect { controller.param! :price, String, blank: true }.to_not raise_error
        end

        it 'succeeds with an empty Array when blank: true' do
          allow(controller).to receive(:params).and_return({ 'array' => [] })
          expect { controller.param! :array, Array, blank: true }.to_not raise_error
        end
      end

      describe 'format parameter' do
        it 'succeeds' do
          allow(controller).to receive(:params).and_return({ 'price' => '50$' })
          expect { controller.param! :price, String, format: /[0-9]+\$/ }.to_not raise_error
        end

        it 'raises' do
          allow(controller).to receive(:params).and_return({ 'price' => '50' })
          expect { controller.param! :price, String, format: /[0-9]+\$/ }.to(
            raise_error(RailsSimpleParams::InvalidFormat,
                        "price must match format #{/[0-9]+\$/}") do |error|
              expect(error.param).to eq 'price'
            end
          )
        end

        it 'succeeds when the value is nil' do
          allow(controller).to receive(:params).and_return({ 'price' => nil })
          expect { controller.param! :price, String, format: /[0-9]+\$/ }.to_not raise_error
          expect(controller.params['price']).to be_nil
        end

        it 'raises MissingParameter when required and absent, even if :format comes first' do
          allow(controller).to receive(:params).and_return({})
          expect { controller.param! :price, String, format: /[0-9]+\$/, required: true }.to(
            raise_error(RailsSimpleParams::MissingParameter, 'price is required')
          )
        end

        it 'raises MissingParameter when required and nil, even if :format comes first' do
          allow(controller).to receive(:params).and_return({ 'price' => nil })
          expect { controller.param! :price, String, format: /[0-9]+\$/, required: true }.to(
            raise_error(RailsSimpleParams::MissingParameter, 'price is required')
          )
        end
      end

      describe 'in parameter (with a range)' do
        before(:each) { allow(controller).to receive(:params).and_return({ 'price' => '50' }) }

        it 'succeeds in the range' do
          controller.param! :price, Integer, in: 1..100
          expect(controller.params['price']).to eq 50
        end

        it 'raises outside the range' do
          expect { controller.param! :price, Integer, in: 51..100 }.to(
            raise_error(RailsSimpleParams::OutOfRange, 'price must be within 51..100') do |error|
              expect(error.param).to eq 'price'
            end
          )
        end

        it 'succeeds with an endless range' do
          Timeout.timeout(1) { controller.param! :price, Integer, in: (1..) }
          expect(controller.params['price']).to eq 50
        end

        it 'succeeds with a beginless range' do
          Timeout.timeout(1) { controller.param! :price, Integer, in: (..100) }
          expect(controller.params['price']).to eq 50
        end

        it 'raises outside an endless range' do
          expect { Timeout.timeout(1) { controller.param! :price, Integer, in: (51..) } }.to(
            raise_error(RailsSimpleParams::OutOfRange, 'price must be within 51..')
          )
        end

        it 'does not enumerate a large range' do
          Timeout.timeout(1) { controller.param! :price, Integer, in: 1..1_000_000_000 }
          expect(controller.params['price']).to eq 50
        end

        it 'succeeds with a Float range' do
          controller.param! :price, Float, in: 1.0..100.0
          expect(controller.params['price']).to eq 50.0
        end

        it 'raises outside a Float range' do
          expect { controller.param! :price, Float, in: 50.5..100.0 }.to(
            raise_error(RailsSimpleParams::OutOfRange, 'price must be within 50.5..100.0')
          )
        end

        it 'raises InvalidConfiguration on an Integer range with non-Integer endpoints' do
          expect { controller.param! :price, Integer, in: 1.5..100 }.to(
            raise_error(RailsSimpleParams::InvalidConfiguration,
                        'Integer param (price) does not allow non-Integer :in options')
          )
        end
      end

      describe 'in paramater (with a set)' do
        before(:each) { allow(controller).to receive(:params).and_return({ 'food' => 'apple' }) }

        it 'succeeds in the range' do
          controller.param! :food, String, in: %w[apple banana cherry]
          expect(controller.params['food']).to eq 'apple'
        end

        it 'raises outside the range' do
          expect { controller.param! :food, String, in: %w[anise basil coriandor] }.to(
            raise_error(RailsSimpleParams::InvalidOption, 'food must be one of ["anise", "basil", "coriandor"]') do |error|
              expect(error.param).to eq 'food'
            end
          )
        end
      end

      describe 'is parameter' do
        it 'succeeds' do
          allow(controller).to receive(:params).and_return({ 'price' => '50' })
          expect { controller.param! :price, String, is: '50' }.to_not raise_error
        end

        it 'raises' do
          allow(controller).to receive(:params).and_return({ 'price' => '51' })
          expect { controller.param! :price, String, is: '50' }.to(
            raise_error(RailsSimpleParams::InvalidIdentity, 'price must be 50') do |error|
              expect(error.param).to eq 'price'
            end
          )
        end
      end

      describe 'max parameter' do
        it 'succeeds' do
          allow(controller).to receive(:params).and_return({ 'price' => '50' })
          expect { controller.param! :price, Integer, max: 50 }.to_not raise_error
        end

        it 'raises' do
          allow(controller).to receive(:params).and_return({ 'price' => '50' })
          expect { controller.param! :price, Integer, max: 49 }.to(
            raise_error(RailsSimpleParams::TooLarge,
                        'price cannot be greater than 49') do |error|
              expect(error.param).to eq 'price'
            end
          )
        end
      end

      describe 'max_length parameter' do
        it 'succeeds' do
          allow(controller).to receive(:params).and_return({ 'word' => 'foo' })
          expect { controller.param! :word, String, max_length: 3 }.to_not raise_error
        end

        it 'raises' do
          allow(controller).to receive(:params).and_return({ 'word' => 'foo' })
          expect { controller.param! :word, String, max_length: 2 }.to(
            raise_error(RailsSimpleParams::TooLong,
                        'word cannot be longer than 2 characters') do |error|
              expect(error.param).to eq 'word'
            end
          )
        end
      end

      describe 'min parameter' do
        it 'succeeds' do
          allow(controller).to receive(:params).and_return({ 'price' => '50' })
          expect { controller.param! :price, Integer, min: 50 }.to_not raise_error
        end

        it 'raises' do
          allow(controller).to receive(:params).and_return({ 'price' => '50' })
          expect { controller.param! :price, Integer, min: 51 }.to(
            raise_error(RailsSimpleParams::TooSmall, 'price cannot be less than 51') do |error|
              expect(error.param).to eq 'price'
            end
          )
        end
      end

      describe 'min_length parameter' do
        it 'succeeds' do
          allow(controller).to receive(:params).and_return({ 'word' => 'foo' })
          expect { controller.param! :word, String, min_length: 3 }.to_not raise_error
        end

        it 'raises' do
          allow(controller).to receive(:params).and_return({ 'word' => 'foo' })
          expect { controller.param! :word, String, min_length: 4 }.to(
            raise_error(RailsSimpleParams::TooShort,
                        'word cannot be shorter than 4 characters') do |error|
              expect(error.param).to eq 'word'
            end
          )
        end
      end

      describe 'custom validator' do
        let(:custom_validation) do
          lambda { |v|
            raise RailsSimpleParams::InvalidParameter, 'Number is not even' if v.odd?
          }
        end

        it 'succeeds when valid' do
          allow(controller).to receive(:params).and_return({ 'number' => '50' })
          controller.param! :number, Integer, custom: custom_validation
          expect(controller.params['number']).to eq 50
        end

        it 'raises when invalid' do
          allow(controller).to receive(:params).and_return({ 'number' => '51' })
          expect { controller.param! :number, Integer, custom: custom_validation }.to(
            raise_error(RailsSimpleParams::InvalidParameter, 'Number is not even') do |error|
              expect(error.param).to be_nil
            end
          )
        end

        it 'is not called with a nil value' do
          allow(controller).to receive(:params).and_return({ 'number' => nil })
          expect { controller.param! :number, Integer, custom: custom_validation }.to_not raise_error
        end
      end

      describe 'validation order' do
        let(:odd_check) do
          lambda { |v|
            raise RailsSimpleParams::InvalidParameter, 'Number is not even' if v.odd?
          }
        end

        it 'raises MissingParameter when :is comes before :required and the param is absent' do
          allow(controller).to receive(:params).and_return({})
          expect { controller.param! :foo, String, is: 'bar', required: true }.to(
            raise_error(RailsSimpleParams::MissingParameter, 'foo is required')
          )
        end

        it 'raises MissingParameter when :custom comes before :required and the param is nil' do
          allow(controller).to receive(:params).and_return({ 'number' => nil })
          expect { controller.param! :number, Integer, custom: odd_check, required: true }.to(
            raise_error(RailsSimpleParams::MissingParameter, 'number is required')
          )
        end

        it 'raises EmptyParameter when :is comes before blank: false and the param is nil' do
          allow(controller).to receive(:params).and_return({ 'foo' => nil })
          expect { controller.param! :foo, String, is: 'bar', blank: false }.to(
            raise_error(RailsSimpleParams::EmptyParameter, 'foo cannot be blank')
          )
        end

        it 'checks :required before blank: false regardless of option order' do
          allow(controller).to receive(:params).and_return({})
          expect { controller.param! :foo, String, blank: false, required: true }.to(
            raise_error(RailsSimpleParams::MissingParameter, 'foo is required')
          )
        end

        it 'skips value validators for a nil value that is not required' do
          allow(controller).to receive(:params).and_return({ 'foo' => nil })
          expect { controller.param! :foo, String, is: 'bar' }.to_not raise_error
          expect(controller.params['foo']).to be_nil
        end

        it 'still runs value validators for a present value when presence options come last' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'baz' })
          expect { controller.param! :foo, String, is: 'bar', required: true }.to(
            raise_error(RailsSimpleParams::InvalidIdentity, 'foo must be bar')
          )
        end

        it 'runs value validators in the order given' do
          allow(controller).to receive(:params).and_return({ 'foo' => 'toolong' })
          expect { controller.param! :foo, String, max_length: 3, in: %w[a b] }.to(
            raise_error(RailsSimpleParams::TooLong)
          )
          expect { controller.param! :foo, String, in: %w[a b], max_length: 3 }.to(
            raise_error(RailsSimpleParams::InvalidOption)
          )
        end
      end
    end
  end
end

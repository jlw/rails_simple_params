require 'spec_helper'
require_relative 'dummy/app/controllers/fake_controller'

describe FakeController, type: :controller do
  def prepare_params(params)
    { params: params }
  end

  describe 'type coercion' do
    let(:object_error_text) do
      if RUBY_VERSION >= '3.4.0'
        %q('{"a" => "b", "c" => "d"}')
      else
        %q('{"a"=>"b", "c"=>"d"}')
      end
    end

    it 'coerces to integer' do
      get :index, **prepare_params(page: '666')

      expect(controller.params[:page]).to eq 666
    end

    it 'raises InvalidType if supplied an array instead of other type (prevent TypeError)' do
      expect { get :index, **prepare_params(page: %w[a b c]) }.to raise_error(
        RailsSimpleParams::InvalidType, %q('["a", "b", "c"]' is not a valid Integer)
      )
    end

    it 'raises InvalidType if supplied a hash instead of other type (prevent TypeError)' do
      expect { get :index, **prepare_params(page: { 'a' => 'b', 'c' => 'd' }) }.to raise_error(
        RailsSimpleParams::InvalidType, "#{object_error_text} is not a valid Integer"
      )
    end

    it 'raises InvalidType if supplied a hash instead of an array (prevent NoMethodError)' do
      expect { get :index, **prepare_params(tags: { 'a' => 'b', 'c' => 'd' }) }.to raise_error(
        RailsSimpleParams::InvalidType, "#{object_error_text} is not a valid Array"
      )
    end
  end

  describe 'nested_hash' do
    it 'validates nested properties' do
      params = {
        'book' => {
          'title' => 'One Hundred Years of Solitude',
          'author' => {
            'first_name' => 'Garbriel Garcia',
            'last_name' => 'Marquez',
            'age' => '70'
          },
          'price' => '$1,000.00'
        }
      }
      get :edit, **prepare_params(params)
      expect(controller.params[:book][:author][:age]).to eq 70
      expect(controller.params[:book][:author][:age]).to be_kind_of Integer
      expect(controller.params[:book][:price]).to eq 1000.0
      expect(controller.params[:book][:price]).to be_instance_of BigDecimal
    end

    it 'raises error when required nested attribute missing' do
      params = {
        'book' => {
          'title' => 'One Hundred Years of Solitude',
          'author' => {
            'last_name' => 'Marquez',
            'age' => '70'
          },
          'price' => '$1,000.00'
        }
      }
      expect { get :edit, **prepare_params(params) }.to(raise_error do |error|
        expect(error).to be_a(RailsSimpleParams::MissingParameter)
        expect(error.param).to eq 'book[author][first_name]'
        expect(error.options).to eq({ required: true })
      end)
    end

    it "passes when hash that's not required but has required attributes is missing" do
      params = {
        'book' => {
          'title' => 'One Hundred Years of Solitude',
          'price' => '$1,000.00'
        }
      }
      get :edit, **prepare_params(params)
      expect(controller.params[:book][:price]).to eq 1000.0
      expect(controller.params[:book][:price]).to be_instance_of BigDecimal
    end
  end

  describe 'InvalidOption' do
    it 'raises an exception with params attributes' do
      expect { get :index, **prepare_params(sort: 'foo') }.to(raise_error do |error|
        expect(error).to be_a(RailsSimpleParams::InvalidOption)
        expect(error.param).to eq 'sort'
        expect(error.options).to eq({ in: %w[asc desc], default: 'asc', transform: :downcase })
      end)
    end
  end

  describe ':transform parameter' do
    it 'applies transformations' do
      get :index, **prepare_params(sort: 'ASC')

      expect(controller.params[:sort]).to eq 'asc'
    end
  end

  describe 'default values' do
    it 'applies default values' do
      get :index

      expect(controller.params[:page]).to eq 1
      expect(controller.params[:sort]).to eq 'asc'
    end
  end

  describe 'nested_array' do
    it 'responds with a 200 when the hash is supplied as a string' do
      expect { get :nested_array, **prepare_params({ filter: 'state' }) }
        .not_to raise_error
    end

    it 'responds with a 200 when the nested array is provided as nil' do
      expect { get :nested_array, **prepare_params({ filter: { state: nil } }) }
        .not_to raise_error
    end
  end

  describe 'nested_array_optional_element' do
    it 'responds with a 200 when the hash is supplied as a string' do
      expect { get :nested_array_optional_element, **prepare_params({ filter: 'state' }) }
        .not_to raise_error
    end

    it 'responds with a 200 when the nested array is provided as nil' do
      expect { get :nested_array_optional_element, **prepare_params({ filter: { state: nil } }) }
        .not_to raise_error
    end
  end

  describe 'nested_array_required_element' do
    it 'responds with a 200 when the hash is supplied as a string' do
      expect { get :nested_array_required_element, **prepare_params({ filter: 'state' }) }
        .not_to raise_error
    end

    it 'responds with a 200 when the nested array is provided as nil' do
      expect { get :nested_array_required_element, **prepare_params({ filter: { state: nil } }) }
        .not_to raise_error
    end
  end

  describe 'array' do
    before { request.headers['Content-Type'] = 'application/json' }

    it 'responds with a 200 when array is not provided' do
      expect { post :ary, **prepare_params({}) }
        .not_to raise_error
    end

    it 'responds with a 200 when when nil is provided' do
      expect { post :ary, **prepare_params({ my_array: nil }) }
        .not_to raise_error
    end
  end

  describe 'array_optional_element' do
    before { request.headers['Content-Type'] = 'application/json' }

    it 'responds with a 200 when array is not provided' do
      expect { post :array_optional_element, **prepare_params({}) }
        .not_to raise_error
    end

    it 'responds with a 200 when when nil is provided' do
      expect { post :array_optional_element, **prepare_params({ my_array: nil }) }
        .not_to raise_error
    end
  end

  describe 'array_required_element' do
    before { request.headers['Content-Type'] = 'application/json' }

    it 'responds with a 200 when array is not provided' do
      expect { post :array_required_element, **prepare_params({}) }
        .not_to raise_error
    end

    it 'responds with a 200 when when nil is provided' do
      expect { post :array_required_element, **prepare_params({ my_array: nil }) }
        .not_to raise_error
    end
  end
end

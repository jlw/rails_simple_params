require 'spec_helper'

describe RailsSimpleParams::Validator::In do
  let(:name) { 'foo' }
  let(:parameter) do
    RailsSimpleParams::Parameter.new(
      name: name,
      value: value,
      options: options,
      type: type
    )
  end

  subject { described_class.new(parameter) }

  context 'with an array' do
    let(:options) { { in: set } }
    let(:type) { String }
    let(:value) { 'apple' }

    describe '#validate!' do
      context 'value given is valid' do
        let(:set) { %w[apple banana cherry] }

        it_behaves_like 'does not raise error'
      end

      context 'value given is invalid' do
        let(:set) { %w[aardvark beaver cheetah] }
        let(:error_message) { 'foo must be one of ["aardvark", "beaver", "cheetah"]' }

        it_behaves_like 'raises InvalidOption'
      end
    end
  end

  context 'with a range' do
    let(:options) { { in: range } }
    let(:type) { Integer }
    let(:value) { 50 }

    describe '#validate!' do
      context 'value given is valid' do
        let(:range) { 1..100 }

        it_behaves_like 'does not raise error'
      end

      context 'value given is invalid' do
        let(:range) { 51..100 }
        let(:error_message) { 'foo must be within 51..100' }

        it_behaves_like 'raises OutOfRange'
      end
    end
  end

  context 'with a proc' do
    let(:options) { { in: -> { ((Time.now.year - 5)..(Time.now.year + 5)) } } }
    let(:type) { Integer }
    let(:value) { Time.now.year }

    describe '#validate!' do
      context 'value given is valid' do
        it_behaves_like 'does not raise error'
      end

      context 'value given is invalid' do
        let(:value) { Time.now.year + 20 }
        let(:error_message) { "foo must be within #{Time.now.year - 5}..#{Time.now.year + 5}" }

        it_behaves_like 'raises OutOfRange'
      end
    end
  end
end

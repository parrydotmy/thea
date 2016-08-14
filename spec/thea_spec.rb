require 'spec_helper'

describe Thea do
  it 'has a version number' do
    expect(Thea::VERSION).not_to be nil
  end

  describe Thea::Translatable do
    it 'translates' do
      str = described_class.new('numbers.one')
      expect(str.to_s).to eq('one')
      expect(in_spanish { str.to_s }).to eq('uno')
    end

    it 'raises when there is no translation and no default' do
      str = described_class.new('numbers.minuszero')
      expect { str.to_s }.to raise_error(I18n::MissingTranslationData)
      expect { in_spanish { str.to_s } }.to raise_error(I18n::MissingTranslationData)
    end

    it 'takes a default' do
      str = described_class.new('numbers.minuszero', default: 'N/A')
      expect(str.to_s).to eq('N/A')
    end

    it 'takes direct interpolations' do
      str = described_class.new('interpolations.one_with_description', description: 'the number one')
      expect(str.to_s).to eq('one: the number one')
    end

    it 'handles interpolated dates' do
      str = described_class.new('interpolations.the_date_was',
                                date: { type: :date, value: Time.parse('2016-01-01') })
      expect(str.to_s).to eq('The date was Fri, 01 Jan 2016 00:00:00 +0100')
      expect(in_spanish { str.to_s }).to eq('La fecha sera viernes, 01 de enero de 2016 00:00:00 +0100')
    end

    it 'formats dates' do
      str = described_class.new('interpolations.the_date_was',
                                date: { type: :date, value: Time.parse('2016-01-01'), opts: { format: :short } })
      expect(str.to_s).to eq('The date was 01 Jan 00:00')
      expect(in_spanish { str.to_s }).to eq('La fecha sera 01 de ene 00:00')
    end

    it 'formats currency' do
      str = described_class.new('interpolations.the_price_is',
                                price: { type: :number_to_currency, value: 10000, opts: { unit: '£' } })
      expect(str.to_s).to eq('The price is £10,000.00')
      expect(in_spanish { str.to_s }).to eq('Te vamos a cobrar 10.000,00 £')
    end

    it 'raises the correct errors when opts are bad' do
      str = described_class.new('interpolations.the_price_is', date: { type: :date, value: Time.parse('2016-01-01')})
      expect{ str.to_s }.to raise_error(I18n::MissingInterpolationArgument)
    end

    it 'serialises to JSON' do
      str = described_class.new('numbers.one')
      expect(str.to_json).to eq("{\"key\":\"numbers.one\",\"opts\":{}}")

      str = described_class.new('interpolations.the_price_is',
                                price: { type: :number_to_currency, value: 10000, opts: { unit: '£' } })
      expect(str.to_json).to eq("{\"key\":\"interpolations.the_price_is\",\"opts\":{\"price\":{\"type\":\"number_to_currency\",\"value\":10000,\"opts\":{\"unit\":\"£\"}}}}")
    end

    it 'unserialises from JSON' do
      str = described_class.new('numbers.one')
      expect(described_class.from_json(str.to_json.to_s).to_json).to eq(str.to_json)
      expect(described_class.from_json(str.to_json.to_s).to_s).to eq(str.to_s)

      str = described_class.new('interpolations.the_price_is',
                                price: { type: :number_to_currency, value: 10000, opts: { unit: '£' } })
      expect(described_class.from_json(str.to_json.to_s).to_json).to eq(str.to_json)
      expect(described_class.from_json(str.to_json.to_s).to_s).to eq(str.to_s)
    end
  end
end

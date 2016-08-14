require 'action_view'

module Thea
  class Translatable
    def initialize(key, unprocessed_opts = {})
      @key = key
      @unprocessed_opts = unprocessed_opts
    end

    def to_s
      I18n.t(@key, { raise: true }.merge(opts))
    end

    def to_json
      JSON.dump({ key: @key, opts: @unprocessed_opts })
    end

    def self.from_json(json)
      data = JSON.parse(json).deep_symbolize_keys
      self.new(data[:key], data[:opts])
    end

    private

    def opts
      @unprocessed_opts.each_with_object({}) do |opt, acc|
        key, value = opt
        if value.is_a? Hash
          case value[:type]
          when :date
            value = I18n.l(value[:value], value[:opts] || {})
          else
            value = interpolation_scope.public_send(value[:type], value[:value], value[:opts] || {})
          end
        end

        acc[key] = value
      end
    end

    def interpolation_scope
      InterpolationScope.new
    end

    class InterpolationScope
      include ActionView::Helpers::NumberHelper
    end
  end
end

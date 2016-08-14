$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'thea'
require 'pry'
require 'json'
require 'rails'

I18n.load_path << Dir.glob(File.expand_path('../locales/*.yml', __FILE__))
I18n.default_locale = 'en'

def t(*args)
  I18n.t(*args)
end

def in_spanish
  I18n.with_locale('es') { yield }
end

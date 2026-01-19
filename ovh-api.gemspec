# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'ovh-api/version'
require 'date'

Gem::Specification.new do |s|
  spec.required_ruby_version = '>= 3.0'
  s.name          = 'ovh-api'
  s.version       = OVHApi::VERSION
  s.summary       = 'OVH API v6 wrapper'
  s.description   = 'Library wrapping OVH API v6 (see: https://api.ovh.com)'
  s.authors       = ['Roland Laurès', 'Benoit Vasseur', 'Zyurs']
  s.email         = 'roland.laures@semifir.com'
  s.files         = Dir.glob('{lib}/**/*') + %w[LICENSE readme.md]
  s.homepage      =
    'https://github.com/ShamoX/ruby-ovh'
  s.license       = 'MIT'
  s.require_path  = 'lib'

  s.has_rdoc      = 'yard'

  s.metadata['rubygems_mfa_required'] = 'true'
end

# frozen_string_literal: true

require_relative 'lib/legion/extensions/mental_time_travel/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-mental-time-travel'
  spec.version       = Legion::Extensions::MentalTimeTravel::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Mental Time Travel'
  spec.description   = "Tulving's chronesthesia for LegionIO — retrospective re-experiencing and prospective " \
                       'pre-experiencing with autonoetic consciousness, vividness decay, and confabulation modeling'
  spec.homepage      = 'https://github.com/LegionIO/lex-mental-time-travel'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = 'https://github.com/LegionIO/lex-mental-time-travel'
  spec.metadata['documentation_uri'] = 'https://github.com/LegionIO/lex-mental-time-travel'
  spec.metadata['changelog_uri']     = 'https://github.com/LegionIO/lex-mental-time-travel'
  spec.metadata['bug_tracker_uri']   = 'https://github.com/LegionIO/lex-mental-time-travel/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
  spec.add_development_dependency 'legion-gaia'
end

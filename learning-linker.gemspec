# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'learning-linker'
  spec.summary = 'Statement logger for LearningLocker LRS'
  spec.version = '0.0.1'
  spec.author = ['Lighthouse Labs', 'Quinn Branscombe']
  spec.files = ['lib/learning-linker.rb', 'lib/post_statement_worker.rb']
  spec.require_paths = ['lib']
  spec.add_dependency 'httparty'
  spec.add_dependency 'sidekiq'
end

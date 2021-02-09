# frozen_string_literal: true

require 'learning-linker'

class PostStatementWorker
  include Sidekiq::Worker

  sidekiq_options retry: true

  def perform(actor, verb, object)
    LearningLinker.post_statement(actor, verb, object)
  end
end

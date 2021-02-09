# frozen_string_literal: true

require 'httparty'
require 'sidekiq'

TEST_ACTOR = {
  "name": 'Learning Linker',
  "mbox": 'mailto:learninglink@lighthouselabs.com'
}.freeze

VERBS = {
  "completed": {
    "id": 'http://activitystrea.ms/schema/1.0/complete',
    "display": {
      "en-US": 'completed'
    }
  },
  "submitted": {
    "id": 'http://activitystrea.ms/schema/1.0/submit',
    "display": {
      "en-US": 'submitted'
    }
  },
  "cancelled": {
    "id": 'http://activitystrea.ms/schema/1.0/cancel',
    "display": {
      "en-US": 'cancelled'
    }
  },
  "viewed": {
    "id": 'http://id.tincanapi.com/verb/viewed',
    "display": {
      "en-US": 'viewed'
    }
  }
}.freeze

OBJECTS = {
  "assistance-request": {
    "id": 'http://lighthouselabs.ca/xapi/activities/assistance-request',
    "definition": {
      "name": { "en-US": 'Assistance Request' },
      "description": { "en-US": "A student's request for assistance from a mentor." },
      "type": 'http://id.tincanapi.com/activitytype/tutor-session'
    }
  },
  "assistance-feedback": {
    "id": 'http://lighthouselabs.ca/xapi/activities/assistance-feedback',
    "definition": {
      "name": { "en-US": 'Assistance Feedback' },
      "description": { "en-US": "A student's feedback for assistance they received from a mentor." },
      "type": 'http://activitystrea.ms/schema/1.0/review'
    }
  },
  "activity": {
    "id": 'http://lighthouselabs.ca/xapi/activities/activity',
    "definition": {
      "name": { "en-US": 'Activity' },
      "description": { "en-US": 'A Compass student activity. Includes readings, exercises, etc.' },
      "type": 'http://id.tincanapi.com/activitytype/school-assignment'
    }
  },
  "activity-feedback": {
    "id": 'http://lighthouselabs.ca/xapi/activities/activity-feedback',
    "definition": {
      "name": { "en-US": 'Activity Feedback' },
      "description": { "en-US": "A student's feedback for a given Compass activity." },
      "type": 'http://id.tincanapi.com/activitytype/school-assignment'
    }
  },
  "project": {
    "id": 'http://lighthouselabs.ca/xapi/activities/project',
    "definition": {
      "name": { "en-US": 'Project' },
      "description": { "en-US": 'A Compass student project. Requires submission and is evaluated by staff.' },
      "type": 'http://id.tincanapi.com/activitytype/project'
    }
  }
}.freeze

module LearningLinker
  # Class for creating statements and posting them to LearningLocker LRS
  class StatementHandler
    def self.format_statement(statement)
      # Verbs can be provided as hash or string.
      # If hash, use directly. If string, perform lookup.
      verb = statement[:verb]
      verb = VERBS[verb.to_sym] if verb.class == String

      # Objects work the same as verbs
      object = statement[:object]
      object = OBJECTS[object.to_sym] if object.class == String

      {
        actor: statement[:actor] || TEST_ACTOR,
        verb: verb,
        object: object,
        context: statement[:context]
      }
    end

    def self.post_statement(statement)
      statement = format_statement(statement)

      HTTParty.post("#{ENV['LRS_XAPI_URL']}/statements", {
                      body: statement.to_json,
                      headers: { 'Authorization': "Basic #{ENV['LRS_XAPI_AUTH']}",
                                 'X-Experience-API-Version': '1.0.3',
                                 'Content-Type': 'application/json' }
                    })
    end
  end

  # Sidekiq worker for posting statements in the background
  class PostStatementWorker
    include Sidekiq::Worker

    def perform(actor, verb, action)
      StatementHandler.post_statement(actor, verb, action)
    end
  end
end

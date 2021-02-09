# frozen_string_literal: true

require 'httparty'

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
  }
}.freeze

class LearningLinker
  def self.get_status
    response = HTTParty.get("#{ENV['LRS_XAPI_URL']}/about")
    puts response
  end

  def self.form_statement(actor, verb, object)
    {
      actor: actor || TEST_ACTOR,
      verb: VERBS[verb.to_sym],
      object: OBJECTS[object.to_sym]
    }
  end

  def self.post_statement(actor, verb, object)
    statement = form_statement(actor, verb, object)

    HTTParty.post("#{ENV['LRS_XAPI_URL']}/statements", {
                    body: statement.to_json,
                    headers: { 'Authorization': 'Basic ' + ENV['LRS_XAPI_AUTH'],
                               'X-Experience-API-Version': '1.0.3',
                               'Content-Type': 'application/json' }
                  })
  end
end

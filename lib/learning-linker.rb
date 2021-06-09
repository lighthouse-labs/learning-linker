# frozen_string_literal: true

module LearningLinker
  require 'httparty'
  require 'sidekiq'

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
    "assistance_request": {
      "id": 'http://lighthouselabs.ca/xapi/activities/assistance-request',
      "definition": {
        "name": { "en-US": 'Assistance Request' },
        "description": { "en-US": "A student's request for assistance from a mentor." },
        "type": 'http://id.tincanapi.com/activitytype/tutor-session'
      }
    },
    "assistance_feedback": {
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
    "activity_feedback": {
      "id": 'http://lighthouselabs.ca/xapi/activities/activity-feedback',
      "definition": {
        "name": { "en-US": 'Activity Feedback' },
        "description": { "en-US": "A student's feedback for a given Compass activity." },
        "type": 'http://id.tincanapi.com/activitytype/review'
      }
    },
    "project": {
      "id": 'http://lighthouselabs.ca/xapi/activities/project',
      "definition": {
        "name": { "en-US": 'Project' },
        "description": { "en-US": 'A Compass student project. Requires submission and is evaluated by staff.' },
        "type": 'http://id.tincanapi.com/activitytype/project'
      }
    },
    "lecture_feedback": {
      "id": 'http://lighthouselabs.ca/xapi/activities/lecture-feedback',
      "definition": {
        "name": { "en-US": 'Lecture Feedback' },
        "description": { "en-US": "A student's feedback for a given lecture in Compass." },
        "type": 'http://id.tincanapi.com/activitytype/review'
      }
    },
    "prep_course": {
      "id": 'http://lighthouselabs.ca/xapi/activities/prep-course',
      "definition": {
        "name": { "en-US": 'Prep Course' },
        "description": { "en-US": "A course given in preparation for one of Compass's programs." },
        "type": 'http://adlnet.gov/expapi/activities/course'
      }
    }
  }.freeze

  EXTENSIONS = {
    "learner_info": 'http://lighthouselabs.ca/xapi/extensions/learner-info',
    "tags": 'http://lighthouselabs.ca/xapi/extensions/tags',
    "mentor_notes": 'http://lighthouselabs.ca/xapi/extensions/mentor-notes',
    "request_reason": 'http://lighthouselabs.ca/xapi/extensions/request-reason',
    "activity_name": 'http://lighthouselabs.ca/xapi/extensions/activity-name',
    "activity_type": 'http://lighthouselabs.ca/xapi/extensions/activity-type',
    "activity_uuid": 'http://lighthouselabs.ca/xapi/extensions/activity-uuid',
    "student_notes": 'http://lighthouselabs.ca/xapi/extensions/student-notes',
    "github_url": 'http://lighthouselabs.ca/xapi/extensions/github-url'
  }.freeze

  # Class for creating statements and posting them to LearningLocker LRS
  class StatementHandler
    # Send a statement to the LRS via HTTP
    def self.post_statement(connection, statement)
      unless connection && connection['xapi_url'] && connection['basic_auth']
        puts 'Warning: Connection info missing or incomplete! No statement was sent.'
        return
      end

      response = HTTParty.post("#{connection['xapi_url']}/statements", {
                                 body: statement.to_json,
                                 headers: { 'Authorization': connection['basic_auth'].to_s,
                                            'X-Experience-API-Version': '1.0.3',
                                            'Content-Type': 'application/json' }
                               })

      if response.code != 200
        raise "Error: LRS did not accept the statement given.\nLRS response: #{response}\nStatement: #{statement.to_json}"
      end
    end
  end

  # Sidekiq worker for posting statements in the background
  class PostStatementWorker
    include Sidekiq::Worker

    sidekiq_options retry: false

    def perform(connection, statement)
      StatementHandler.post_statement(connection, statement)
    end
  end
end

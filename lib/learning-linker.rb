# frozen_string_literal: true

module LearningLinker
  require 'httparty'
  require 'sidekiq'

  VERBS = {
    "attempted": {
      "id": 'http://adlnet.gov/expapi/verbs/attempted',
      "display": {
        "en-US": 'attempted'
      }
    },
    "cancelled": {
      "id": 'http://activitystrea.ms/schema/1.0/cancel',
      "display": {
        "en-US": 'cancelled'
      }
    },
    "completed": {
      "id": 'http://activitystrea.ms/schema/1.0/complete',
      "display": {
        "en-US": 'completed'
      }
    },
    "received": {
      "id": 'http://activitystrea.ms/schema/1.0/receive',
      "display": {
        "en-US": 'received'
      }
    },
    "started": {
      "id": 'http://activitystrea.ms/schema/1.0/start',
      "display": {
        "en-US": 'started'
      }
    },
    "submitted": {
      "id": 'http://activitystrea.ms/schema/1.0/submit',
      "display": {
        "en-US": 'submitted'
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
    "assistance": {
      "id": 'http://lighthouselabs.ca/xapi/activities/assistance',
      "definition": {
        "name": { "en-US": 'Assistance' },
        "description": { "en-US": 'A meeting in which a student speaks with a mentor for advice or help.' },
        "type": 'http://id.tincanapi.com/activitytype/tutor-session'
      }
    },
    "assistance_feedback": {
      "id": 'http://lighthouselabs.ca/xapi/activities/assistance-feedback',
      "definition": {
        "name": { "en-US": 'Assistance Feedback' },
        "description": { "en-US": 'Feedback from either student or mentor about an assistance.' },
        "type": 'http://activitystrea.ms/schema/1.0/review'
      }
    },
    "assistance_request": {
      "id": 'http://lighthouselabs.ca/xapi/activities/assistance-request',
      "definition": {
        "name": { "en-US": 'Assistance Request' },
        "description": { "en-US": "A student's request for assistance from a mentor." },
        "type": 'http://id.tincanapi.com/activitytype/tutor-session'
      }
    },
    "daily_feedback": {
      "id": 'http://lighthouselabs.ca/xapi/activities/daily-feedback',
      "definition": {
        "name": { "en-US": 'Daily Feedback' },
        "description": { "en-US": "A student's feedback for a given program day in Compass." },
        "type": 'http://id.tincanapi.com/activitytype/review'
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
    "project": {
      "id": 'http://lighthouselabs.ca/xapi/activities/project',
      "definition": {
        "name": { "en-US": 'Project' },
        "description": { "en-US": 'A Compass student project. Requires submission and is evaluated by staff.' },
        "type": 'http://id.tincanapi.com/activitytype/project'
      }
    },
    "quiz": {
      "id": 'http://lighthouselabs.ca/xapi/activities/quiz',
      "definition": {
        "name": { "en-US": 'Quiz' },
        "description": { "en-US": 'A quiz presented to a student in Compass. Used to assess student progress on learning outcomes.' },
        "type": 'http://id.tincanapi.com/activitytype/school-assignment'
      }
    }
  }.freeze

  EXTENSIONS = {
    "assistance_id": 'http://lighthouselabs.ca/xapi/extensions/assistance-id',
    "activity_day": 'http://lighthouselabs.ca/xapi/extensions/activity-day',
    "activity_name": 'http://lighthouselabs.ca/xapi/extensions/activity-name',
    "activity_prep": 'http://lighthouselabs.ca/xapi/extensions/activity-prep',
    "activity_stretch": 'http://lighthouselabs.ca/xapi/extensions/activity-stretch',
    "activity_type": 'http://lighthouselabs.ca/xapi/extensions/activity-type',
    "activity_uuid": 'http://lighthouselabs.ca/xapi/extensions/activity-uuid',
    "cohort": 'http://lighthouselabs.ca/xapi/extensions/cohort',
    "curriculum_day": 'http://lighthouselabs.ca/xapi/extensions/curriculum-day',
    "first_attempt": 'http://lighthouselabs.ca/xapi/extensions/first_attempt',
    "github_url": 'http://lighthouselabs.ca/xapi/extensions/github-url',
    "learner_info": 'http://lighthouselabs.ca/xapi/extensions/learner-info',
    "mentor_notes": 'http://lighthouselabs.ca/xapi/extensions/mentor-notes',
    "request_id": 'http://lighthouselabs.ca/xapi/extensions/request-id',
    "request_reason": 'http://lighthouselabs.ca/xapi/extensions/request-reason',
    "skipped_questions": 'http://lighthouselabs.ca/xapi/extensions/skipped-questions',
    "student_notes": 'http://lighthouselabs.ca/xapi/extensions/student-notes',
    "tags": 'http://lighthouselabs.ca/xapi/extensions/tags'
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

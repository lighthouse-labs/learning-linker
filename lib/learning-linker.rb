# frozen_string_literal: true

module LearningLinker
  require 'httparty'

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
    "progressed": {
      "id": 'http://adlnet.gov/expapi/verbs/progressed',
      "display": {
        "en-US": 'progressed'
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
    "day_feedback": {
      "id": 'http://lighthouselabs.ca/xapi/activities/day-feedback',
      "definition": {
        "name": { "en-US": 'Day Feedback' },
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
    "programming_test": {
      "id": 'http://lighthouselabs.ca/xapi/activities/programming_test',
      "definition": {
        "name": { "en-US": 'Programming Test' },
        "description": { "en-US": "An evaluation of a student's problem-solving abilities using code submissions and an automated scoring system." },
        "type": 'http://adlnet.gov/expapi/activities/assessment'
      }
    },
    "project_evaluation": {
      "id": 'http://lighthouselabs.ca/xapi/activities/project-evaluation',
      "definition": {
        "name": { "en-US": 'Project Evaluation' },
        "description": { "en-US": "An evaluation given by a mentor for a student's project." },
        "type": 'http://id.tincanapi.com/activitytype/review'
      }
    },
    "tech_interview": {
      "id": 'http://lighthouselabs.ca/xapi/activities/quiz',
      "definition": {
        "name": { "en-US": 'Technical Interview' },
        "description": { "en-US": 'A meeting between a mentor and student to determine knowledge and application level of student.' },
        "type": 'http://adlnet.gov/expapi/activities/assessment'
      }
    },
    "quiz": {
      "id": 'http://lighthouselabs.ca/xapi/activities/quiz',
      "definition": {
        "name": { "en-US": 'Quiz' },
        "description": { "en-US": 'A quiz presented to a student in Compass. Used to assess student progress on learning outcomes.' },
        "type": 'http://adlnet.gov/expapi/activities/assessment'
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
    "deployment": 'http://lighthouselabs.ca/xapi/extensions/deployment',
    "exam_code": 'http://lighthouselabs.ca/xapi/extensions/exam-code',
    "first_attempt": 'http://lighthouselabs.ca/xapi/extensions/first_attempt',
    "github_url": 'http://lighthouselabs.ca/xapi/extensions/github-url',
    "initial_score": 'http://lighthouselabs.ca/xapi/extensions/initial-score',
    "learner_info": 'http://lighthouselabs.ca/xapi/extensions/learner-info',
    "mentor_notes": 'http://lighthouselabs.ca/xapi/extensions/mentor-notes',
    "mood": 'http://lighthouselabs.ca/xapi/extensions/mood',
    "overdue": 'http://lighthouselabs.ca/xapi/extensions/overdue',
    "program": 'http://lighthouselabs.ca/xapi/extensions/program',
    "queue_wait_seconds": 'http://lighthouselabs.ca/xapi/extensions/queue-wait-seconds',
    "request_id": 'http://lighthouselabs.ca/xapi/extensions/request-id',
    "request_reason": 'http://lighthouselabs.ca/xapi/extensions/request-reason',
    "score_details": 'http://lighthouselabs.ca/xapi/extensions/score-details',
    "skipped_questions": 'http://lighthouselabs.ca/xapi/extensions/skipped-questions',
    "status": 'http://lighthouselabs.ca/xapi/extensions/status',
    "student_notes": 'http://lighthouselabs.ca/xapi/extensions/student-notes',
    "student_uid": 'http://lighthouselabs.ca/xapi/extensions/student-uid',
    "tags": 'http://lighthouselabs.ca/xapi/extensions/tags',
    "time_limit_minutes": 'http://lighthouselabs.ca/xapi/extensions/time-limit-minutes'
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
end

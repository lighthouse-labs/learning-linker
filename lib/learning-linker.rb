# frozen_string_literal: true

require 'httparty'

TEST_STATEMENT = [{
  "actor": {
    "name": 'Quinn',
    "mbox": 'mailto:quinn@lighthouselabs.com'
  },
  "verb": {
    "id": 'http://activitystrea.ms/schema/1.0/completed',
    "display": {
      "en-US": 'completed'
    }
  },
  "object": {
    "id": 'http://adlnet.gov/expapi/activities/test',
    "definition": {
      "type": 'http://lighthouselabs.ca/xapi/activities/test',
      "name": {
        "en-US": 'HTTP Request Test'
      }
    }
  }
}].to_json

class LearningLinker
  def self.get_status
    response = HTTParty.get("#{ENV['LRS_XAPI_URL']}/about")
    puts response
  end

  def self.post_statement
    HTTParty.post("#{ENV['LRS_XAPI_URL']}/statements", {
                    body: TEST_STATEMENT,
                    headers: { 'Authorization': 'Basic ' + ENV['LRS_XAPI_AUTH'],
                               'X-Experience-API-Version': '1.0.3',
                               'Content-Type': 'application/json' }
                  })
  end
end

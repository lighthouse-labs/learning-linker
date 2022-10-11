# Learning Linker

Custom Ruby gem for communicating with LearningLocker instances using the xAPI spec. Provides a simplified interface for posting statements in Rails projects, as well as a built-in dictionary of statement terms used commonly by LHL products.

## Setup

To add this gem to your Rails project, add the following line to your gemfile, using the latest tagged release:

`gem 'learning-linker', git: 'https://github.com/lighthouse-labs/learning-linker.git', tag: '[latest tagged version in Releases]'`

Then run `bundle`!

## Using in a project

Once the gem is installed in your project, you can start posting statements! There are two functions you can use for this, and they both take hashes of connection information and an xAPI statement as parameters.

To post a statement synchronously:

```ruby
LearningLinker::StatementHandler.post_statement(<connection>, <statement>)
```

### Asynchronous Statement Posting

If your project uses `sidekiq`, we highly recommend adding a worker script to handle posting statements asynchronously. Example of a simple worker to accomplish this:

```ruby
class PostStatementWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5 # optional; allows sidekiq to retry post up to 5 times, in case of failure

  def perform(connection, statement)
    StatementHandler.post_statement(connection, statement)
  end
end
```

Once added to your project, you can call `PostStatementWorker.perform_async`, with the same arguments taken by `LearningLinker::StatementHandler.post_statement`, to post a statement asynchronously!

## Connection hash

The connection hash expected by LearningLinker requires two properties, both relating to values you can find in your LearningLocker instance's "client" section:

- `xapi_url` - xAPI Endpoint. Example: `https://locker.example.com/data/xAPI`
- `basic_auth` - Basic auth token string, with "Basic " prepended. Example: `Basic OWY3YmRmNzkxZjBkMjA5MzBmM2JlMGVkYTQ1Y2E0OTZhYjExampleToyMmU3OGQ3YjQ5MGJhYWRlNTg5NTgwNzg5ZTA1ZjRkOTQ3YjRkMDg5`

### Statement constants

While you're free to form a complete custom statement from scratch, this gem also provides constants defining verbs, objects and extensions for common uses in our projects.

`LearningLinker::VERBS`

- `:attempted`
- `:cancelled`
- `:completed`
- `:progressed`
- `:received`
- `:started`
- `:submitted`
- `:viewed`

`LearningLinker::OBJECTS`

- `:activity`
- `:activity_feedback`
- `:assistance`
- `:assistance_feedback`
- `:assistance_request`
- `:day_feedback`
- `:lecture_feedback`
- `:programming_test`
- `:project`
- `:project_evaluation`
- `:tech_interview`
- `:quiz`

`LearningLinker::EXTENSIONS`

- `:assistance_id`
- `:activity_day`
- `:activity_name`
- `:activity_prep`
- `:activity_stretch`
- `:activity_type`
- `:activity_uuid`
- `:cohort`
- `:curriculum_day`
- `:deployment`
- `:exam_code`
- `:enrollment_id`
- `:first_attempt`
- `:github_url`
- `:initial_score`
- `:learner_info`
- `:mentor_notes`
- `:mood`
- `:overdue`
- `:program`
- `:queue_wait_seconds`
- `:request_id`
- `:request_reason`
- `:score_details`
- `:skipped_questions`
- `:status`
- `:student_notes`
- `:student_uid`
- `:tags`
- `:time_limit_minutes`

### Example statement post call

To put it all together, here's an example call that might be made when a student (`@student`) views an activity (`@activity`):

```ruby
  LearningLinker::StatementHandler.post_statement(
    {
      xapi_url: "https://locker.example.com/data/xAPI"
      basic_auth: "Basic OWY3YmRmNzkxZjBkMjA5MzBmM2JlMGVkYTQ1Y2E0OTZhYjExampleToyMmU3OGQ3YjQ5MGJhYWRlNTg5NTgwNzg5ZTA1ZjRkOTQ3YjRkMDg5"
    },
    {
      actor:   {
        name:       @student.name,
        mbox:       "mailto:#{@student.email}",
        objectType: "Agent"
      },
      verb:    LearningLinker::VERBS[:viewed],
      object:  LearningLinker::OBJECTS[:activity],
      context: {
        extensions: {
          "#{LearningLinker::EXTENSIONS[:activity_name]}": @activity.name,
          "#{LearningLinker::EXTENSIONS[:activity_type]}": @activity.type,
          "#{LearningLinker::EXTENSIONS[:activity_uuid]}": @activity.uuid
        }
      }
    })
```

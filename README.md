# Learning Linker

Custom Ruby gem for communicating with LearningLocker instances using the xAPI spec.

## Setup

To add this gem to your Rails project, add the following line to your gemfile, using the latest tagged release:

`gem 'learning-linker', git: 'https://github.com/lighthouse-labs/learning-linker.git', tag: '[latest tagged version in Releases]'`

Then run `bundle`!

## Using in a project

Once the gem is installed in your project, you can start posting statements! There are two functions you can use for this, and they both take hashes of connection information and an xAPI statement as parameters.

For asynchronous statement posting, if you're working with `sidekiq` (recommended):

```ruby
LearningLinker::PostStatementWorker.perform_async(<connection>, <statement>)
```

If `sidekiq` is not a part of your project, you can post the statement synchronously with:

```ruby
LearningLinker::StatementHandler.post_statement(<connection>, <statement>)
```

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
- `:daily_feedback`
- `:lecture_feedback`
- `:project`
- `:project_evaluation`
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
- `:first_attempt`
- `:github_url`
- `:learner_info`
- `:mentor_notes`
- `:mood`
- `:request_id`
- `:request_reason`
- `:skipped_questions`
- `:student_notes`
- `:tags`

### Example statement post call

To put it all together, here's an example call that might be made when a student (`@student`) views an activity (`@activity`):

```ruby
  LearningLinker::PostStatementWorker.perform_async(
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

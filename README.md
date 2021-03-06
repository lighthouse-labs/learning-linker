# Learning Linker

Custom Ruby gem for communicating with LearningLocker instances using the xAPI spec.

## Setup

To add this gem to your Rails project, add the following line to your gemfile, using the latest tagged release:

`gem 'learning-linker', git: 'https://github.com/lighthouse-labs/learning-linker.git', tag: '[latest tagged version in Releases]'`

Then run `bundle`!

### Environment Variables

Ensure your Rails environment has the following environment variables:

| `LRS_XAPI_URL`  | URL leading to the xAPI endpoint of your LearningLocker LRS |
| --------------- | ----------------------------------------------------------- |
| `LRS_XAPI_AUTH` | Basic Authorization token for the LearningLocker instance   |

## Using in a project

Once the gem is installed in your project and the environment is set up, you can start posting statements! There are two functions you can use for this, and they both take an xAPI statement hash as a parameter:

For asynchronous statement posting, if you're working with `sidekiq` (recommended):

```ruby
LearningLinker::PostStatementWorker.perform_async(...)
```

If `sidekiq` is not a part of your project, you can post the statement synchronously with:

```ruby
LearningLinker::StatementHandler.post_statement(...)
```

### Statement constants

While you're free to form a complete custom statement from scratch, this gem also provides constants defining verbs, objects and extensions for common uses in our projects.

`LearningLinker::VERBS`

- `:completed`
- `:submitted`
- `:cancelled`
- `:viewed`

`LearningLinker::OBJECTS`

- `:assistance_request`
- `:assistance_feedback`
- `:activity`
- `:activity_feedback`
- `:project`
- `:lecture_feedback`
- `:prep_course`

`LearningLinker::EXTENSIONS`

- `:learner_info`
- `:tags`
- `:mentor_notes`
- `:request_reason`
- `:activity_name`
- `:activity_type`
- `:activity_uuid`
- `:student_notes`
- `:github_url`

### Example statement post call

To put it all together, here's an example call that might be made when a student (`@student`) views an activity (`@activity`):

```ruby
  LearningLinker::PostStatementWorker.perform_async({
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

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

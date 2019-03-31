# set additional env variable to which environment hte error is
# coming from is clear

def bat_environment
  Raven.tags_context(bat_environment: ENV['SENTRY_ENVIRONMENT'])
end

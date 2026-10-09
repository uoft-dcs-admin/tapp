# frozen_string_literal: true

require 'shellwords'

set :deployment_path, '/home/tapp-runner/tapp'
set :docker_path, '/usr/bin/docker'
set :flock_path, '/usr/bin/flock'

set :job_template, nil
set :output, File.join(deployment_path, 'log/offer_summaries.log')

# Define custom 'whenever' cron job for emailing offer activity summaries to instructors, with the
# details specified in a Rake task in offer_summaries.rake
job_type :offer_summaries,
         "cd #{Shellwords.escape(deployment_path)} && " \
         "#{Shellwords.escape(flock_path)} -n #{Shellwords.escape(File.join(deployment_path,
                                                                            'log/offer_summaries.lock'))} " \
         "#{Shellwords.escape(docker_path)} compose -f docker-compose.yml -f docker-compose.prod.yml " \
         "exec -T backend bundle exec rake 'offers:email_summaries[:task]' :output"

# Production setting, offer activity emails will be sent daily at 9am
every 1.day, at: '9:00 am' do
    offer_summaries '86400'
end

# Uncomment the following lines to run the offer summaries job every minute for testing purposes
# every 1.minute do
#     offer_summaries '60'
# end

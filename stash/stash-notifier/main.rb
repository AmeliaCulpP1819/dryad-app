#!/usr/bin/env ruby

Dir.chdir(__dir__) # gets bundler.require(:default) working from any directory

require 'rubygems'
require 'bundler/setup'
Dir[File.join(__dir__, 'app', '*.rb')].sort.each { |file| require file }
require 'active_support/core_ext/object/to_query'

Bundler.require(:default)

Config.initialize(environment: (ENV['STASH_ENV'] || 'development'), logger_std_out: ENV['NOTIFIER_OUTPUT'] == 'stdout')

State.create_pid

Config.logger.info("Starting notifier run for #{Config.environment} environment")

State.ensure_statefile

begin
  # get records for each set and time range
  State.sets.each do |set|
    begin
      set.retry_errored_dryad_notifications
      set.notify_dryad

      # If something has been retried every 5 minutes for 30 days and Dryad doesn't know about it, then it was probably deleted
      # from Dryad and not from Merritt and it's time to stop retrying.  We have logs of this stuff if people care to clean up.
      set.clean_retry_items!(days: 30)

      # save the state to the file after each set has run
      State.save_sets_state
    rescue HTTPClient::TimeoutError, HTTPClient::BadResponseError => e
      Config.logger.error("Timeout error for set #{set.name}\n#{e}\n#{e.backtrace.join("\n")}")
    end
  end
ensure
  Config.logger.info("Finished notifier run for #{Config.environment} environment\n")
  State.remove_pid
end


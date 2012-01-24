require 'tork/config'

Tork::Config.reabsorb_file_greps.push(
  %r<^features/support/.+\.rb$>,
  %r<^config/cucumber\.yml$>
)

Tork::Config.test_file_globbers.update(
  # source files that correspond to test files
  %r<^(features/.+/)step_definitions/.+\.rb$> => proc { $1 + '*.feature' },

  # the actual test files themselves
  %r<^features/.+\.feature$> => lambda {|path| path }
)

# bootstrap cucumber to run the test file
Tork::Config.after_fork_hooks << lambda do |worker_number, log_file, test_file, test_names|
  # noopify test_file load in Tork::Master#test()
  require 'tempfile'
  feature_file = test_file.dup
  test_file.replace Tempfile.new('tork').path

  # pass test_file to cucumber(1) in ARGV
  at_exit do
    unless $!
      ARGV << feature_file
      require 'cucumber'
      require 'rubygems'
      load Gem.bin_path('cucumber', 'cucumber')
    end
  end
end

require "rake/testtask"

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task :'redis:start' => :'redis:stop' do
  `redis-server test/redis.conf`
end

task :'redis:stop' do
  `kill 9 $(cat test/redis.pid)` if File.exists?('test/redis.pid')
end


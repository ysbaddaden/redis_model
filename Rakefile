require "rdoc/task"
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

Rake::RDocTask.new do |rdoc|
  rdoc.title = "Janus"
  rdoc.main = "README.rdoc"
  rdoc.rdoc_dir = "doc"
  rdoc.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rdoc.options << "--charset=utf-8"
end

begin
  require 'jeweler'

  Jeweler::Tasks.new do |gem|
    root_files = FileList["README.rdoc"]
    gem.name = "redis_model"
    gem.version = "0.1.0"
    gem.summary = "Object Mapper for Redis storage."
    gem.email = "julien@portalier.com"
    gem.homepage = "http://github.com/ysbaddaden/redis_model"
    gem.description = "RedisModel is an ActiveModel based object mapper for the Redis NoSQL database."
    gem.authors = ['Julien Portalier']
    gem.files = root_files + FileList["{lib}/*"] + FileList["{lib}/**/*"]
    gem.extra_rdoc_files = root_files
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: gem install jeweler"
end


require 'redis'

require 'active_support/concern'
require 'active_model/naming'
require 'active_model/dirty'
require 'active_model/mass_assignment_security'
require 'active_model/conversion'

require File.expand_path('../redis_model/attributes', __FILE__)
require File.expand_path('../redis_model/connection', __FILE__)
require File.expand_path('../redis_model/validations', __FILE__)
require File.expand_path('../redis_model/persistance', __FILE__)
require File.expand_path('../redis_model/serializers', __FILE__)
require File.expand_path('../redis_model/finders', __FILE__)
require File.expand_path('../redis_model/base', __FILE__)


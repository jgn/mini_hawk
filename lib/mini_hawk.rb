module MiniHawk
  class HawkError < StandardError; end
  class InvalidCrendentialsError < HawkError; end
  class UnknownAlgorithmError < HawkError; end
end

require 'faraday_middleware/response_middleware'
require 'mini_hawk/utils'
require 'mini_hawk/client'
require 'mini_hawk/hawkify'

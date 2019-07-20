require "mini_store/version"
require "mini_store/checkout"
require "logger"

module MiniStore
  class Error < StandardError; end

  LOGGER = Logger.new(STDOUT).freeze

  def self.log(message, level = :info)
    LOGGER.public_send(level, message)
  end
end

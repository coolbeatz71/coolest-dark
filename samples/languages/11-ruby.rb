# frozen_string_literal: true

##
# Ruby language tour.
#
# Covers modules, mixins, symbols, blocks, procs, metaprogramming,
# exceptions, pattern matching and string interpolation.
module LanguageTour
  # Severity levels for a log line.
  module Severity
    DEBUG   = :debug
    INFO    = :info
    WARNING = :warning
    ERROR   = :error
    ALL = [DEBUG, INFO, WARNING, ERROR].freeze
  end

  # Mixin contributing timestamp behaviour.
  module Timestamped
    def created_at = Time.now.utc
  end

  # Raised when no entry matches.
  class NotFoundError < StandardError
    attr_reader :id

    def initialize(id)
      @id = id
      super("missing #{id}")
    end
  end

  # An immutable value type.
  LogEntry = Struct.new(:message, :severity, :tags, keyword_init: true) do
    include Timestamped

    def to_s = "[#{severity}] #{message} (#{Array(tags).size} tags)"
  end

  # In-memory repository.
  class LogRepository
    include Enumerable

    def initialize(store = {})
      @store = store # inline comment
    end

    def each(&block) = @store.each_value(&block)

    # @param id [Integer] the identifier to look up
    # @return [LogEntry] the matching entry
    # @raise [NotFoundError] when nothing matches
    def find_by_id!(id)
      @store.fetch(id) { raise NotFoundError, id }
    end

    def describe(outcome)
      case outcome
      in [0, *]            then "empty"
      in [_, Severity::ERROR] then "failing"
      in [Integer => n, *] if n > 100 then "busy"
      else "ok"
      end
    end

    def recent(take)
      select { |e| e.severity == Severity::ERROR }
        .map(&:message)
        .first(take)
    end

    def method_missing(name, *args)
      name.to_s.start_with?("find_") ? find_by_id!(args.first) : super
    end

    def respond_to_missing?(name, include_private = false)
      name.to_s.start_with?("find_") || super
    end
  end
end

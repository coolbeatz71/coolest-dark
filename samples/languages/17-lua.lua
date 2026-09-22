--- Lua language tour.
-- Covers tables, metatables, closures, varargs, coroutines and modules.
-- @module languagetour

local M = {}

--- Severity levels for a log line.
-- @table Severity
M.Severity = { DEBUG = 1, INFO = 2, WARNING = 3, ERROR = 4 }

--- An immutable-ish value type built on a metatable.
-- @type LogEntry
local LogEntry = {}
LogEntry.__index = LogEntry

--- Creates a new entry.
-- @param message string the human readable text
-- @param severity number one of @{Severity}
-- @return LogEntry
function LogEntry.new(message, severity)
  local self = setmetatable({}, LogEntry)
  self.message = message
  self.severity = severity or M.Severity.INFO
  self.tags = {} -- inline comment
  return self
end

function LogEntry:__tostring()
  return string.format("[%d] %s (%d tags)", self.severity, self.message, #self.tags)
end

--- In-memory repository.
local LogRepository = {}
LogRepository.__index = LogRepository

function LogRepository.new()
  return setmetatable({ store = {} }, LogRepository)
end

function LogRepository:findById(id)
  return self.store[id]
end

--- Variadic function with multiple returns.
function LogRepository:addAll(...)
  local added, skipped = 0, 0
  for _, entry in ipairs({ ... }) do
    if entry then
      self.store[#self.store + 1] = entry
      added = added + 1
    else
      skipped = skipped + 1
    end
  end
  return added, skipped
end

--- Coroutine based iteration.
function LogRepository:watchAll(limit)
  return coroutine.wrap(function()
    local i = 0
    for _, entry in pairs(self.store) do
      i = i + 1
      if i > (limit or 20) then return end
      coroutine.yield(entry)
    end
  end)
end

function LogRepository:describe(count, severity)
  if count == 0 then
    return "empty"
  elseif severity == M.Severity.ERROR then
    return "failing"
  elseif count > 100 then
    return "busy"
  end
  return "ok"
end

M.LogEntry = LogEntry
M.LogRepository = LogRepository
return M

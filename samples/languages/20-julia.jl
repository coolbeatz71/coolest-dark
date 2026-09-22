"""
    LanguageTour

Julia language tour: modules, multiple dispatch, structs, type parameters,
macros, broadcasting, comprehensions and exception handling.
"""
module LanguageTour

export Severity, LogEntry, LogRepository, describe, recent

"""
    Severity

Severity levels for a log line.
"""
@enum Severity DEBUG = 1 INFO = 2 WARNING = 3 ERROR = 4

"""
    LogEntry(message; severity=INFO, tags=String[])

An immutable value type.

# Arguments
- `message::AbstractString`: the human readable text
- `severity::Severity`: how serious the line is
- `tags::Vector{String}`: optional labels

# Throws
- `ArgumentError` when `message` is empty.
"""
struct LogEntry
    message::String
    severity::Severity
    tags::Vector{String}

    function LogEntry(message::AbstractString; severity::Severity = INFO, tags = String[])
        isempty(message) && throw(ArgumentError("message required"))
        new(String(message), severity, collect(tags))  # inline comment
    end
end

Base.show(io::IO, e::LogEntry) =
    print(io, "[$(e.severity)] $(e.message) ($(length(e.tags)) tags)")

"""Generic in-memory repository."""
mutable struct LogRepository{T,ID<:Union{Int,String}}
    store::Dict{ID,T}
end

LogRepository{T,ID}() where {T,ID} = LogRepository{T,ID}(Dict{ID,T}())

"""Find one entry, or `nothing`."""
function find_by_id(repo::LogRepository{T,ID}, id::ID)::Union{T,Nothing} where {T,ID}
    get(repo.store, id, nothing)
end

# Multiple dispatch on the second argument.
describe(count::Integer, ::Val{ERROR}) = "failing"
describe(count::Integer, ::Val{S}) where {S} =
    count == 0 ? "empty" : count > 100 ? "busy" : "ok"

"""Comprehension plus broadcasting."""
function recent(repo::LogRepository, take::Integer)
    severe = [e for e in values(repo.store) if e.severity >= WARNING]
    messages = getfield.(severe, :message)
    first(messages, take)
end

end # module

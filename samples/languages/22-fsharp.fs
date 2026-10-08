/// F# language tour.
///
/// Covers modules, discriminated unions, records, pattern matching,
/// computation expressions, pipelines and active patterns.
module LanguageTour.FSharp

open System
open System.Threading.Tasks

/// Severity levels for a log line.
type Severity =
    | Debug
    | Info
    | Warning
    | Error

/// An immutable record.
type LogEntry =
    { Message: string
      Severity: Severity
      Tags: string list }

    override this.ToString() =
        sprintf "[%A] %s (%d tags)" this.Severity this.Message (List.length this.Tags)

/// A discriminated union modelling the result.
type Outcome<'T> =
    | Success of 'T
    | Failure of exn
    | Empty

/// Generic repository contract.
///
/// <param name="id">the identifier to look up</param>
/// <returns>the entity, or None</returns>
type IRepository<'T, 'TId> =
    abstract FindById: id: 'TId -> Task<'T option>

/// Active pattern for classifying counts.
let (|Zero|Small|Large|) count =
    if count = 0 then Zero
    elif count > 100 then Large
    else Small

type LogRepository() =
    let store = System.Collections.Generic.Dictionary<int, LogEntry>()

    interface IRepository<LogEntry, int> with
        member _.FindById(id) =
            task {
                do! Task.Delay 10 // inline comment
                match store.TryGetValue id with
                | true, entry -> return Some entry
                | _ -> return None
            }

    member _.Describe(count, severity) =
        match count, severity with
        | Zero, _ -> "empty"
        | _, Error -> "failing"
        | Large, _ -> "busy"
        | _ -> "ok"

    member _.Recent(take) =
        store.Values
        |> Seq.filter (fun e -> e.Severity = Error || e.Severity = Warning)
        |> Seq.map (fun e -> e.Message)
        |> Seq.truncate take
        |> List.ofSeq

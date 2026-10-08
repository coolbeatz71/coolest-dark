package languagetour.scala

import scala.concurrent.{ExecutionContext, Future}
import scala.util.{Failure, Success, Try}

/** Scala language tour.
  *
  * Covers traits, case classes, sealed hierarchies, pattern matching,
  * higher-order functions, implicits/givens, for-comprehensions,
  * type classes, variance and collections.
  */
object LanguageTour:

  /** Severity levels for a log line. */
  enum Severity(val rank: Int):
    case Debug   extends Severity(1)
    case Info    extends Severity(2)
    case Warning extends Severity(3)
    case Error   extends Severity(4)

  /** An immutable value type. */
  final case class LogEntry(
      message: String,
      severity: Severity = Severity.Info,
      tags: List[String] = Nil
  ):
    override def toString: String =
      s"[${severity}] $message (${tags.size} tags)" // inline comment

  /** A sealed hierarchy for exhaustive matching. */
  sealed trait Outcome[+A]
  final case class Success_[A](value: A) extends Outcome[A]
  final case class Failure_(cause: Throwable) extends Outcome[Nothing]
  case object Empty extends Outcome[Nothing]

  /** Generic repository contract with a covariant result.
    *
    * @tparam T  the stored entity type
    * @tparam Id the identifier type
    * @throws NoSuchElementException when nothing matches
    */
  trait Repository[T, Id]:
    def findById(id: Id): Future[Option[T]]
    def watchAll(limit: Int = 20): LazyList[T]

  /** A type class for rendering. */
  trait Show[A]:
    extension (a: A) def show: String

  given Show[LogEntry] with
    extension (entry: LogEntry) def show: String = entry.message.toUpperCase

  final class LogRepository(using ec: ExecutionContext) extends Repository[LogEntry, Int]:
    private var store: Map[Int, LogEntry] = Map.empty

    def findById(id: Int): Future[Option[LogEntry]] = Future:
      store.get(id)

    def watchAll(limit: Int): LazyList[LogEntry] =
      LazyList.from(store.values).take(limit)

    /** Pattern matching with guards and destructuring. */
    def describe(count: Int, severity: Severity): String = (count, severity) match
      case (0, _)                      => "empty"
      case (_, Severity.Error)         => "failing"
      case (n, _) if n > 100           => "busy"
      case _                           => "ok"

    /** For-comprehension over Futures. */
    def summarise(ids: List[Int]): Future[List[String]] =
      for
        maybeEntries <- Future.traverse(ids)(findById)
        entries       = maybeEntries.flatten
        severe        = entries.filter(_.severity.rank >= Severity.Warning.rank)
      yield severe.map(_.show)

    def safeParse(raw: String): Either[String, Int] =
      Try(raw.toInt) match
        case Success(value) => Right(value)
        case Failure(error) => Left(error.getMessage)

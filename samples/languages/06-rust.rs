//! # Rust language tour
//!
//! Covers traits, generics, lifetimes, enums, pattern matching,
//! error handling, iterators, closures and async.

use std::collections::HashMap;
use std::fmt;
use std::sync::Arc;

/// Severity levels for a log line.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum Severity { Debug, Info, Warning, Error }

/// Generic repository contract.
///
/// # Type Parameters
/// * `T`  - the stored entity type
/// * `Id` - the identifier type
///
/// # Errors
/// Returns [`RepoError`] when the repository is closed.
pub trait Repository<T, Id>
where
    Id: std::hash::Hash + Eq,
{
    fn find_by_id(&self, id: &Id) -> Result<Option<&T>, RepoError>;
}

/// Errors this module can produce.
#[derive(Debug)]
pub enum RepoError { Closed, NotFound { id: i64 } }

impl fmt::Display for RepoError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            RepoError::Closed => write!(f, "closed"),
            RepoError::NotFound { id } => write!(f, "missing {id}"),
        }
    }
}

/// An immutable value type.
#[derive(Debug, Clone)]
pub struct LogEntry<'a> {
    pub message: &'a str,
    pub severity: Severity,
    pub tags: Vec<String>,
}

pub struct LogRepository<'a> {
    store: HashMap<i64, LogEntry<'a>>,
    hooks: Arc<Vec<Box<dyn Fn(&LogEntry<'a>) -> bool + Send + Sync>>>,
}

impl<'a> Repository<LogEntry<'a>, i64> for LogRepository<'a> {
    fn find_by_id(&self, id: &i64) -> Result<Option<&LogEntry<'a>>, RepoError> {
        // inline comment
        Ok(self.store.get(id))
    }
}

impl<'a> LogRepository<'a> {
    /// Iterator chain with a closure.
    pub fn recent(&self, take: usize) -> Vec<&'a str> {
        self.store
            .values()
            .filter(|e| e.severity >= Severity::Warning)
            .map(|e| e.message)
            .take(take)
            .collect()
    }

    pub fn describe(&self, count: usize, severity: Severity) -> &'static str {
        match (count, severity) {
            (0, _) => "empty",
            (_, Severity::Error) => "failing",
            (n, _) if n > 100 => "busy",
            _ => "ok",
        }
    }
}

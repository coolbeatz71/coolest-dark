/**
 * @file 13-c.c
 * @brief C language tour: structs, enums, unions, pointers, macros.
 *
 * Covers preprocessor directives, typedefs, function pointers,
 * bit fields, static/extern linkage and manual memory management.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_TAGS 16
#define ARRAY_LEN(a) (sizeof(a) / sizeof((a)[0]))

/** Severity levels for a log line. */
typedef enum {
    SEVERITY_DEBUG = 0,
    SEVERITY_INFO,
    SEVERITY_WARNING,
    SEVERITY_ERROR
} severity_t;

/** An immutable-ish value type. */
typedef struct log_entry {
    const char *message;
    severity_t  severity;
    char       *tags[MAX_TAGS];
    unsigned    tag_count : 8;  /* bit field */
} log_entry_t;

/** A tagged union. */
typedef struct {
    enum { OUTCOME_OK, OUTCOME_ERR } kind;
    union {
        log_entry_t entry;
        int         error_code;
    } as;
} outcome_t;

/** Function pointer type for a filter predicate. */
typedef int (*filter_fn)(const log_entry_t *entry);

static int is_severe(const log_entry_t *entry) {
    return entry != NULL && entry->severity >= SEVERITY_WARNING;
}

/**
 * Copies matching messages into @p out.
 *
 * @param entries source array
 * @param count   number of entries
 * @param out     destination, caller owned
 * @param take    maximum results
 * @return number written, or -1 on bad arguments
 */
int recent(const log_entry_t *entries, size_t count, const char **out, size_t take, filter_fn pred) {
    if (entries == NULL || out == NULL) return -1;

    size_t written = 0;
    for (size_t i = 0; i < count && written < take; ++i) {
        if (pred(&entries[i])) {
            out[written++] = entries[i].message; /* inline comment */
        }
    }
    return (int)written;
}

const char *describe(size_t count, severity_t severity) {
    switch (severity) {
        case SEVERITY_ERROR:  return "failing";
        case SEVERITY_WARNING: return count > 100 ? "busy" : "ok";
        default:              return count == 0 ? "empty" : "ok";
    }
}

int main(void) {
    log_entry_t entries[] = {
        { .message = "hello", .severity = SEVERITY_ERROR, .tag_count = 0 },
    };
    const char *out[ARRAY_LEN(entries)];
    int n = recent(entries, ARRAY_LEN(entries), out, ARRAY_LEN(out), is_severe);
    printf("%d -> %s\n", n, describe((size_t)n, SEVERITY_ERROR));
    return EXIT_SUCCESS;
}

-- =============================================================
-- SQL language tour
--
-- Covers DDL, constraints, indexes, views, CTEs, window functions,
-- aggregates, joins, triggers and stored procedures.
-- =============================================================

/* Severity lookup table. */
CREATE TABLE severity (
    id          SMALLINT     PRIMARY KEY,
    name        VARCHAR(16)  NOT NULL UNIQUE,
    is_severe   BOOLEAN      NOT NULL DEFAULT FALSE
);

INSERT INTO severity (id, name, is_severe) VALUES
    (1, 'debug',   FALSE),
    (2, 'info',    FALSE),
    (3, 'warning', TRUE),
    (4, 'error',   TRUE);

/* Main log table with a foreign key and a check constraint. */
CREATE TABLE log_entry (
    id           BIGSERIAL     PRIMARY KEY,
    message      TEXT          NOT NULL CHECK (length(message) > 0),
    severity_id  SMALLINT      NOT NULL REFERENCES severity (id) ON DELETE RESTRICT,
    tags         TEXT[]        DEFAULT '{}',
    created_at   TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX idx_log_entry_severity ON log_entry (severity_id, created_at DESC);

-- Most recent severe messages, with a window function.
WITH ranked AS (
    SELECT
        le.id,
        le.message,
        s.name                                          AS severity,
        cardinality(le.tags)                            AS tag_count,
        ROW_NUMBER() OVER (
            PARTITION BY le.severity_id
            ORDER BY le.created_at DESC
        )                                               AS rn,
        COUNT(*) OVER ()                                AS total
    FROM log_entry AS le
    INNER JOIN severity AS s ON s.id = le.severity_id
    WHERE s.is_severe = TRUE
      AND le.created_at >= now() - INTERVAL '7 days'
)
SELECT
    r.message,
    r.severity,
    CASE
        WHEN r.total = 0        THEN 'empty'
        WHEN r.severity = 'error' THEN 'failing'
        WHEN r.total > 100      THEN 'busy'
        ELSE 'ok'
    END AS state
FROM ranked AS r
WHERE r.rn <= 5
ORDER BY r.severity, r.message
LIMIT 20 OFFSET 0;

CREATE OR REPLACE VIEW v_severe_log AS
    SELECT id, message FROM log_entry WHERE severity_id >= 3;

CREATE OR REPLACE FUNCTION describe(p_count INTEGER, p_severity TEXT)
RETURNS TEXT
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    IF p_count = 0 THEN
        RETURN 'empty';
    ELSIF p_severity = 'error' THEN
        RETURN 'failing';   -- inline comment
    END IF;
    RETURN CASE WHEN p_count > 100 THEN 'busy' ELSE 'ok' END;
END;
$$;

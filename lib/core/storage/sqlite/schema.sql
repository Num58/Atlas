-- PrimeAtlas local-first SQLite schema (architecture §7.1)
-- Applied verbatim by SqliteEventLogRepository / SqlitePortraitRepository.

CREATE TABLE IF NOT EXISTS events (
  id          TEXT PRIMARY KEY,
  event_type  TEXT NOT NULL,
  payload     TEXT NOT NULL,          -- JSON
  session_id  TEXT,
  created_at  INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_events_type_time ON events(event_type, created_at);

CREATE TABLE IF NOT EXISTS portrait_versions (
  version_id        TEXT PRIMARY KEY,
  created_at        INTEGER NOT NULL,
  snapshot          TEXT NOT NULL,    -- JSON(ProfileSnapshot)
  change_summary    TEXT NOT NULL,
  consent_record_id TEXT NOT NULL
);

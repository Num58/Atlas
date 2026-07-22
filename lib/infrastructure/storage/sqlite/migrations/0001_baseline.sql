PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;
PRAGMA synchronous = FULL;
PRAGMA busy_timeout = 1000;

CREATE TABLE schema_migrations (
  version INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  checksum TEXT NOT NULL,
  applied_at_us INTEGER NOT NULL,
  app_version TEXT NOT NULL
);

CREATE TABLE subjects (
  id TEXT PRIMARY KEY,
  subject_kind TEXT NOT NULL CHECK (subject_kind IN ('guest','local_account')),
  status TEXT NOT NULL CHECK (status IN ('active','inactive')),
  created_at_us INTEGER NOT NULL,
  updated_at_us INTEGER NOT NULL
);
CREATE UNIQUE INDEX ux_subjects_active_kind ON subjects(subject_kind) WHERE status = 'active';

CREATE TABLE devices (
  id TEXT PRIMARY KEY,
  owner_id TEXT NOT NULL,
  platform TEXT NOT NULL CHECK (platform IN ('android','ios','test')),
  app_version TEXT NOT NULL,
  installation_id TEXT NOT NULL,
  next_device_seq INTEGER NOT NULL CHECK (next_device_seq >= 1),
  last_seen_at_us INTEGER NOT NULL,
  created_at_us INTEGER NOT NULL,
  updated_at_us INTEGER NOT NULL,
  UNIQUE (owner_id,id),
  UNIQUE (owner_id,installation_id),
  FOREIGN KEY (owner_id) REFERENCES subjects(id) ON DELETE RESTRICT
);
CREATE INDEX idx_devices_owner_seen ON devices(owner_id,last_seen_at_us DESC);

CREATE TABLE identity_drafts (
  id TEXT PRIMARY KEY,
  owner_id TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('draft','pending_confirmation','confirmed','discarded','superseded')),
  version INTEGER NOT NULL CHECK (version >= 1),
  current_identity_text TEXT,
  target_identity_text TEXT,
  answers_json TEXT NOT NULL DEFAULT '{}',
  data_sufficiency TEXT NOT NULL CHECK (data_sufficiency IN ('insufficient','partial','sufficient')),
  source_type TEXT NOT NULL CHECK (source_type IN ('user_declared','device_observed','imported','system_inferred','model_generated','professional_content','local_rule')),
  based_on_portrait_version_id TEXT,
  submitted_at_us INTEGER,
  confirmed_at_us INTEGER,
  superseded_by_draft_id TEXT,
  created_at_us INTEGER NOT NULL,
  updated_at_us INTEGER NOT NULL,
  UNIQUE (owner_id,id),
  UNIQUE (owner_id,id,version),
  FOREIGN KEY (owner_id) REFERENCES subjects(id) ON DELETE RESTRICT,
  FOREIGN KEY (owner_id,based_on_portrait_version_id) REFERENCES portrait_versions(owner_id,id) DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (owner_id,superseded_by_draft_id) REFERENCES identity_drafts(owner_id,id) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX idx_identity_drafts_owner_status ON identity_drafts(owner_id,status,updated_at_us DESC);
CREATE UNIQUE INDEX ux_identity_drafts_pending ON identity_drafts(owner_id) WHERE status = 'pending_confirmation';

CREATE TABLE portrait_candidates (
  id TEXT PRIMARY KEY,
  owner_id TEXT NOT NULL,
  base_portrait_version_id TEXT,
  source_draft_id TEXT,
  status TEXT NOT NULL CHECK (status IN ('candidate','pending_confirmation','accepted','rejected','withdrawn','conflicted')),
  version INTEGER NOT NULL CHECK (version >= 1),
  candidate_json TEXT NOT NULL,
  evidence_summary_json TEXT NOT NULL DEFAULT '[]',
  source_type TEXT NOT NULL CHECK (source_type IN ('user_declared','device_observed','imported','system_inferred','model_generated','professional_content','local_rule')),
  created_at_us INTEGER NOT NULL,
  updated_at_us INTEGER NOT NULL,
  UNIQUE (owner_id,id),
  FOREIGN KEY (owner_id,base_portrait_version_id) REFERENCES portrait_versions(owner_id,id) DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (owner_id,source_draft_id) REFERENCES identity_drafts(owner_id,id),
  FOREIGN KEY (owner_id) REFERENCES subjects(id) ON DELETE RESTRICT
);
CREATE INDEX idx_portrait_candidates_owner_status ON portrait_candidates(owner_id,status,updated_at_us DESC);

CREATE TABLE portrait_versions (
  id TEXT PRIMARY KEY,
  owner_id TEXT NOT NULL,
  ordinal INTEGER NOT NULL CHECK (ordinal >= 1),
  lifecycle TEXT NOT NULL CHECK (lifecycle IN ('active','superseded')),
  kind TEXT NOT NULL CHECK (kind IN ('confirmed','restored')),
  snapshot_json TEXT NOT NULL,
  change_summary TEXT NOT NULL,
  confirmation_source TEXT NOT NULL CHECK (confirmation_source = 'user_explicit'),
  confirmed_draft_id TEXT,
  accepted_candidate_id TEXT,
  based_on_version_id TEXT,
  restored_from_version_id TEXT,
  activated_at_us INTEGER NOT NULL,
  created_at_us INTEGER NOT NULL,
  updated_at_us INTEGER NOT NULL,
  UNIQUE (owner_id,id),
  UNIQUE (owner_id,ordinal),
  FOREIGN KEY (owner_id,confirmed_draft_id) REFERENCES identity_drafts(owner_id,id),
  FOREIGN KEY (owner_id,accepted_candidate_id) REFERENCES portrait_candidates(owner_id,id),
  FOREIGN KEY (owner_id,based_on_version_id) REFERENCES portrait_versions(owner_id,id),
  FOREIGN KEY (owner_id,restored_from_version_id) REFERENCES portrait_versions(owner_id,id),
  FOREIGN KEY (owner_id) REFERENCES subjects(id) ON DELETE RESTRICT,
  CHECK ((kind = 'confirmed' AND confirmed_draft_id IS NOT NULL AND restored_from_version_id IS NULL)
      OR (kind = 'restored' AND restored_from_version_id IS NOT NULL))
);
CREATE UNIQUE INDEX ux_portrait_versions_active ON portrait_versions(owner_id) WHERE lifecycle = 'active';
CREATE INDEX idx_portrait_versions_owner_time ON portrait_versions(owner_id,activated_at_us DESC,id DESC);

CREATE TABLE active_domains (
  id TEXT PRIMARY KEY,
  owner_id TEXT NOT NULL,
  domain_code TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('active','paused','archived')),
  priority INTEGER NOT NULL CHECK (priority BETWEEN 1 AND 3),
  version INTEGER NOT NULL CHECK (version >= 1),
  source_portrait_version_id TEXT NOT NULL,
  paused_at_us INTEGER,
  archived_at_us INTEGER,
  created_at_us INTEGER NOT NULL,
  updated_at_us INTEGER NOT NULL,
  UNIQUE (owner_id,id),
  UNIQUE (owner_id,domain_code),
  FOREIGN KEY (owner_id,source_portrait_version_id) REFERENCES portrait_versions(owner_id,id),
  FOREIGN KEY (owner_id) REFERENCES subjects(id) ON DELETE RESTRICT
);
CREATE UNIQUE INDEX ux_active_domains_priority ON active_domains(owner_id,priority) WHERE status = 'active';
CREATE INDEX idx_domains_owner_status ON active_domains(owner_id,status,priority);

CREATE TABLE goals (
  id TEXT PRIMARY KEY,
  owner_id TEXT NOT NULL,
  domain_id TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('draft','pending_confirmation','active','paused','recalibrating','completed','archived')),
  version INTEGER NOT NULL CHECK (version >= 1),
  title TEXT NOT NULL,
  description TEXT,
  identity_gap_json TEXT NOT NULL,
  data_sufficiency TEXT NOT NULL CHECK (data_sufficiency IN ('insufficient','partial','sufficient')),
  source_type TEXT NOT NULL CHECK (source_type IN ('user_declared','device_observed','imported','system_inferred','model_generated','professional_content','local_rule')),
  source_portrait_version_id TEXT,
  target_at_us INTEGER,
  paused_at_us INTEGER,
  completed_at_us INTEGER,
  archived_at_us INTEGER,
  created_at_us INTEGER NOT NULL,
  updated_at_us INTEGER NOT NULL,
  UNIQUE (owner_id,id),
  UNIQUE (owner_id,id,version),
  FOREIGN KEY (owner_id,domain_id) REFERENCES active_domains(owner_id,id),
  FOREIGN KEY (owner_id,source_portrait_version_id) REFERENCES portrait_versions(owner_id,id),
  FOREIGN KEY (owner_id) REFERENCES subjects(id) ON DELETE RESTRICT
);
CREATE INDEX idx_goals_owner_domain_status ON goals(owner_id,domain_id,status,updated_at_us DESC);
CREATE INDEX idx_goals_owner_updated ON goals(owner_id,updated_at_us DESC,id DESC);

CREATE TABLE milestones (
  id TEXT PRIMARY KEY,
  owner_id TEXT NOT NULL,
  goal_id TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('not_started','in_progress','achieved','not_achieved','superseded')),
  version INTEGER NOT NULL CHECK (version >= 1),
  title TEXT NOT NULL,
  sequence_no INTEGER NOT NULL CHECK (sequence_no >= 1),
  rule_type TEXT NOT NULL CHECK (rule_type IN ('quantitative','evidence')),
  rule_json TEXT NOT NULL,
  starts_at_us INTEGER,
  target_at_us INTEGER,
  achieved_at_us INTEGER,
  superseded_by_id TEXT,
  created_at_us INTEGER NOT NULL,
  updated_at_us INTEGER NOT NULL,
  UNIQUE (owner_id,id),
  UNIQUE (owner_id,goal_id,sequence_no),
  FOREIGN KEY (owner_id,goal_id) REFERENCES goals(owner_id,id),
  FOREIGN KEY (owner_id,superseded_by_id) REFERENCES milestones(owner_id,id),
  FOREIGN KEY (owner_id) REFERENCES subjects(id) ON DELETE RESTRICT
);
CREATE INDEX idx_milestones_owner_goal ON milestones(owner_id,goal_id,sequence_no);
CREATE INDEX idx_milestones_owner_status ON milestones(owner_id,status,updated_at_us DESC);

CREATE TABLE evidence_links (
  id TEXT PRIMARY KEY,
  owner_id TEXT NOT NULL,
  subject_type TEXT NOT NULL CHECK (subject_type IN ('identity_draft','portrait_candidate','portrait_version','goal','milestone')),
  subject_id TEXT NOT NULL,
  evidence_type TEXT NOT NULL CHECK (evidence_type IN ('user_statement','local_event','version_reference')),
  evidence_ref_id TEXT,
  summary TEXT NOT NULL,
  validity TEXT NOT NULL CHECK (validity IN ('valid','invalidated','superseded')),
  source_type TEXT NOT NULL CHECK (source_type IN ('user_declared','device_observed','imported','system_inferred','model_generated','professional_content','local_rule')),
  invalidated_at_us INTEGER,
  created_at_us INTEGER NOT NULL,
  updated_at_us INTEGER NOT NULL,
  UNIQUE (owner_id,id),
  FOREIGN KEY (owner_id) REFERENCES subjects(id) ON DELETE RESTRICT
);
CREATE INDEX idx_evidence_subject ON evidence_links(owner_id,subject_type,subject_id,validity,created_at_us DESC);

CREATE TABLE domain_events (
  id TEXT PRIMARY KEY,
  owner_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  schema_version INTEGER NOT NULL CHECK (schema_version = 1),
  aggregate_type TEXT NOT NULL,
  aggregate_id TEXT NOT NULL,
  aggregate_version INTEGER NOT NULL CHECK (aggregate_version >= 1),
  operation_id TEXT NOT NULL,
  causation_id TEXT,
  correlation_id TEXT,
  source_type TEXT NOT NULL CHECK (source_type IN ('user_declared','device_observed','imported','system_inferred','model_generated','professional_content','local_rule')),
  actor_type TEXT NOT NULL,
  actor_ref_id TEXT,
  device_id TEXT NOT NULL,
  device_seq INTEGER NOT NULL CHECK (device_seq >= 1),
  occurred_at_us INTEGER NOT NULL,
  timezone_id TEXT NOT NULL,
  timezone_offset_min INTEGER NOT NULL CHECK (timezone_offset_min BETWEEN -840 AND 840),
  recorded_at_us INTEGER NOT NULL,
  payload_json TEXT NOT NULL,
  payload_hash TEXT NOT NULL CHECK (length(payload_hash) = 64 AND payload_hash = lower(payload_hash)),
  created_at_us INTEGER NOT NULL,
  updated_at_us INTEGER NOT NULL,
  UNIQUE (owner_id,id),
  UNIQUE (owner_id,device_id,device_seq),
  FOREIGN KEY (owner_id,device_id) REFERENCES devices(owner_id,id),
  FOREIGN KEY (owner_id) REFERENCES subjects(id) ON DELETE RESTRICT,
  CHECK (updated_at_us = created_at_us)
);
CREATE INDEX idx_events_owner_aggregate ON domain_events(owner_id,aggregate_type,aggregate_id,aggregate_version);
CREATE INDEX idx_events_owner_type_time ON domain_events(owner_id,event_type,occurred_at_us DESC,id DESC);
CREATE INDEX idx_events_owner_operation ON domain_events(owner_id,operation_id);

CREATE TABLE audit_records (
  id TEXT PRIMARY KEY,
  owner_id TEXT NOT NULL,
  operation_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  object_type TEXT NOT NULL,
  object_id TEXT NOT NULL,
  actor_type TEXT NOT NULL,
  before_version INTEGER,
  after_version INTEGER,
  reason_code TEXT,
  metadata_json TEXT NOT NULL DEFAULT '{}',
  occurred_at_us INTEGER NOT NULL,
  created_at_us INTEGER NOT NULL,
  updated_at_us INTEGER NOT NULL,
  UNIQUE (owner_id,id),
  FOREIGN KEY (owner_id) REFERENCES subjects(id) ON DELETE RESTRICT,
  CHECK (updated_at_us = created_at_us)
);
CREATE INDEX idx_audit_owner_object ON audit_records(owner_id,object_type,object_id,occurred_at_us DESC,id DESC);
CREATE INDEX idx_audit_owner_operation ON audit_records(owner_id,operation_id);

CREATE TABLE operation_ledger (
  id TEXT PRIMARY KEY,
  owner_id TEXT NOT NULL,
  operation_id TEXT NOT NULL,
  device_id TEXT NOT NULL,
  device_seq INTEGER NOT NULL CHECK (device_seq >= 1),
  operation_type TEXT NOT NULL CHECK (operation_type IN ('create','update','archive','restore')),
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  base_version INTEGER,
  payload_json TEXT NOT NULL,
  payload_hash TEXT NOT NULL CHECK (length(payload_hash) = 64 AND payload_hash = lower(payload_hash)),
  result_json TEXT,
  state TEXT NOT NULL CHECK (state IN ('committed','rejected')),
  error_code TEXT,
  created_at_us INTEGER NOT NULL,
  updated_at_us INTEGER NOT NULL,
  UNIQUE (owner_id,id),
  UNIQUE (owner_id,operation_id),
  UNIQUE (owner_id,device_id,device_seq),
  FOREIGN KEY (owner_id,device_id) REFERENCES devices(owner_id,id),
  FOREIGN KEY (owner_id) REFERENCES subjects(id) ON DELETE RESTRICT,
  CHECK ((state = 'committed' AND result_json IS NOT NULL AND error_code IS NULL)
      OR (state = 'rejected' AND result_json IS NULL AND error_code IS NOT NULL)),
  CHECK (updated_at_us = created_at_us)
);
CREATE INDEX idx_operation_ledger_owner_state_seq ON operation_ledger(owner_id,state,device_seq);
CREATE INDEX idx_operation_ledger_owner_entity ON operation_ledger(owner_id,entity_type,entity_id,created_at_us DESC);

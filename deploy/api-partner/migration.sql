-- Partner attribution on care events (idempotent).
ALTER TABLE care_events
  ADD COLUMN IF NOT EXISTS created_by_user_id UUID REFERENCES users(id);

ALTER TABLE care_events
  ADD COLUMN IF NOT EXISTS created_by_display_name VARCHAR(120) DEFAULT '';
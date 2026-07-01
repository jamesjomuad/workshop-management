-- Soft delete for contacts
ALTER TABLE contacts ADD COLUMN deleted_at TIMESTAMPTZ;
CREATE INDEX idx_contacts_deleted ON contacts(deleted_at);

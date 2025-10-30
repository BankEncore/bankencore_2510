class EnforcePreferredNameSameParty < ActiveRecord::Migration[7.2]
  def up
    # 1) Ensure a unique key exists on the referenced columns
    safety_assured do
    execute <<~SQL
      ALTER TABLE parties_names
      ADD CONSTRAINT uq_parties_names_id_party UNIQUE (id, party_id);
    SQL
    end

    # 2) Remove any prior FK on preferred_party_name_id alone (if present)
    safety_assured do
    execute <<~SQL
      DO $$
      DECLARE
        conname text;
      BEGIN
        SELECT c.conname INTO conname
        FROM pg_constraint c
        JOIN pg_class t ON t.oid = c.conrelid
        WHERE t.relname = 'parties_parties'
          AND c.contype = 'f'
          AND array_position(c.conkey, (
                SELECT attnum FROM pg_attribute
                WHERE attrelid = t.oid AND attname = 'preferred_party_name_id'
              )) IS NOT NULL;
        IF conname IS NOT NULL THEN
          EXECUTE format('ALTER TABLE parties_parties DROP CONSTRAINT %I', conname);
        END IF;
      END$$;
    SQL
    end

    # 3) Add the composite FK that guarantees “same party”
    safety_assured do
    execute <<~SQL
      ALTER TABLE parties_parties
      ADD CONSTRAINT fk_pref_name_same_party
      FOREIGN KEY (preferred_party_name_id, id)
      REFERENCES parties_names(id, party_id)
      ON UPDATE RESTRICT
      ON DELETE SET NULL;
    SQL
    end
  end

  def down
    execute "ALTER TABLE parties_parties DROP CONSTRAINT IF EXISTS fk_pref_name_same_party;"
    execute "ALTER TABLE parties_names DROP CONSTRAINT IF EXISTS uq_parties_names_id_party;"
  end
end

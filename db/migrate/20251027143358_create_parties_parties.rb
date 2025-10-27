# db/migrate/20251027143358_create_parties_parties.rb
class CreatePartiesParties < ActiveRecord::Migration[8.0]
  def up
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    create_table :parties_parties do |t|
      t.uuid   :public_id, default: -> { "gen_random_uuid()" }, null: false
      t.string :profile_number, null: false
      t.string :relationship_to_institution_code, null: false, default: "customer"
      t.bigint :preferred_party_name_id
      t.date   :established_on, null: false, default: -> { "CURRENT_DATE" }
      t.string :withholding_option_code
      t.timestamps
    end

    add_index :parties_parties, :public_id, unique: true
    add_index :parties_parties, :profile_number, unique: true
    add_index :parties_parties, :relationship_to_institution_code
    add_index :parties_parties, :withholding_option_code

    safety_assured do
      execute <<~SQL
        CREATE SEQUENCE IF NOT EXISTS seq_party_serial START WITH 1001 MINVALUE 1;

        CREATE OR REPLACE FUNCTION util_luhn_checksum(num_text text)
        RETURNS int LANGUAGE plpgsql IMMUTABLE AS $$
        DECLARE
          sum int := 0; d int; dbl boolean := false; c char;
        BEGIN
          FOR i IN REVERSE length(num_text)..1 LOOP
            c := substr(num_text, i, 1);
            IF c ~ '[0-9]' THEN
              d := (c)::int;
              IF dbl THEN d := d*2; IF d>9 THEN d := d-9; END IF; END IF;
              sum := sum + d;
              dbl := NOT dbl;
            END IF;
          END LOOP;
          RETURN (10 - (sum % 10)) % 10;
        END$$;

        CREATE OR REPLACE FUNCTION alloc_party_profile_number()
        RETURNS text LANGUAGE plpgsql AS $$
        DECLARE
          base bigint;
          yy   text := to_char(CURRENT_DATE, 'YY');
          candidate text;
        BEGIN
          LOOP
            base := nextval('seq_party_serial');
            IF base > 9999999 THEN
              PERFORM setval('seq_party_serial', 1, false);
              base := nextval('seq_party_serial');
            END IF;

            candidate := base::text || yy;
            candidate := candidate || util_luhn_checksum(candidate);

            EXIT WHEN NOT EXISTS (
              SELECT 1 FROM parties_parties WHERE profile_number = candidate
            );
          END LOOP;
          RETURN candidate;
        END$$;

        CREATE OR REPLACE FUNCTION set_party_profile_number()
        RETURNS trigger LANGUAGE plpgsql AS $$
        BEGIN
          IF NEW.profile_number IS NULL OR NEW.profile_number = '' THEN
            NEW.profile_number := alloc_party_profile_number();
          END IF;
          RETURN NEW;
        END$$;

        DROP TRIGGER IF EXISTS trg_parties_profile_number ON parties_parties;
        CREATE TRIGGER trg_parties_profile_number
        BEFORE INSERT ON parties_parties
        FOR EACH ROW EXECUTE FUNCTION set_party_profile_number();
      SQL
    end
  end

  def down
    safety_assured do
      execute <<~SQL
        DROP TRIGGER IF EXISTS trg_parties_profile_number ON parties_parties;
        DROP FUNCTION IF EXISTS set_party_profile_number();
        DROP FUNCTION IF EXISTS alloc_party_profile_number();
        DROP FUNCTION IF EXISTS util_luhn_checksum(text);
        DROP SEQUENCE IF EXISTS seq_party_serial;
      SQL
    end

    drop_table :parties_parties
  end
end

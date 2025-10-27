# db/migrate/20251027190000_add_party_number_allocator.rb
class AddPartyNumberAllocator < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      execute <<~SQL
        -- 7-digit sequential part rolls to 001001 when exceeding 9,999,999
        CREATE SEQUENCE IF NOT EXISTS seq_party_serial START WITH 1001 MINVALUE 1;

        CREATE OR REPLACE FUNCTION util_luhn_checksum(num_text text)
        RETURNS int LANGUAGE plpgsql IMMUTABLE AS $$
        DECLARE
          sum int := 0; d int; dbl boolean := false; c char;
        BEGIN
          -- compute check digit for the given string of digits
          FOR i IN REVERSE length(num_text)..1 LOOP
            c := substr(num_text, i, 1);
            d := (c)::int;
            IF dbl THEN d := d*2; IF d>9 THEN d := d-9; END IF; END IF;
            sum := sum + d;
            dbl := NOT dbl;
          END LOOP;
          RETURN (10 - (sum % 10)) % 10;
        END$$;

        CREATE OR REPLACE FUNCTION alloc_party_profile_number()
        RETURNS text LANGUAGE plpgsql AS $$
        DECLARE
          base bigint;
          seq7 text;
          yy   text := to_char(CURRENT_DATE, 'YY');
          body text;
          candidate text;
        BEGIN
          LOOP
            base := nextval('seq_party_serial');

            IF base > 9999999 THEN
              -- set to 1000 so nextval() -> 1001
              PERFORM setval('seq_party_serial', 1000, false);
              base := nextval('seq_party_serial');
            END IF;

            seq7 := lpad(base::text, 7, '0');        -- 7-digit, zero-padded
            body := seq7 || yy;                       -- 9 digits: seq(7) + year(2)
            candidate := body || util_luhn_checksum(body)::text; -- 10th is Luhn

            EXIT WHEN NOT EXISTS (
              SELECT 1 FROM parties_parties WHERE profile_number = candidate
            );
          END LOOP;

          RETURN candidate; -- always 10 digits
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
      SQL
    end
  end
end

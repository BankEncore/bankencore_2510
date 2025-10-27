# db/migrate/20251027143519_create_parties_relationships.rb
class CreatePartiesRelationships < ActiveRecord::Migration[8.0]
  def change
    create_table :parties_relationships do |t|
      t.bigint :source_party_id, null: false
      t.bigint :target_party_id, null: false
      t.string :relationship_type_code, null: false
      t.decimal :ownership_percent, precision: 5, scale: 2
      t.string  :status_code
      t.date    :valid_from
      t.date    :valid_to
      t.timestamps
    end

    add_index :parties_relationships, [ :source_party_id, :target_party_id, :relationship_type_code ], name: "idx_party_rel_key"
    add_index :parties_relationships, :status_code

    safety_assured do
    execute <<~SQL
      ALTER TABLE parties_relationships
      ADD CONSTRAINT chk_party_rel_not_self CHECK (source_party_id <> target_party_id);
      ALTER TABLE parties_relationships
      ADD CONSTRAINT chk_valid_range_rel CHECK (valid_to IS NULL OR valid_from IS NULL OR valid_from <= valid_to);
    SQL
    end

    add_foreign_key :parties_relationships, :parties_parties, column: :source_party_id, validate: false
    add_foreign_key :parties_relationships, :parties_parties, column: :target_party_id, validate: false
  end
end

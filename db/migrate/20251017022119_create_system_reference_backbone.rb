# db/migrate/20251017022119_create_system_reference_backbone.rb
class CreateSystemReferenceBackbone < ActiveRecord::Migration[8.0]
  def change
    create_table :system_reference_lists do |t|
      t.uuid   :public_id, default: "gen_random_uuid()", null: false
      t.string :key, null: false
      t.string :name, null: false
      t.string :description
      t.string :schema_version
      t.string :visibility, null: false, default: "public"
      t.string :tags, array: true, default: []
      t.timestamps
    end
    add_index :system_reference_lists, :public_id, unique: true
    add_index :system_reference_lists, :key,       unique: true

    create_table :system_reference_values do |t|
      t.uuid    :public_id, default: "gen_random_uuid()", null: false
      t.bigint  :system_reference_list_id, null: false    # FK added later
      t.bigint  :parent_id                                     # self-FK added later
      t.string  :key,        null: false
      t.string  :code
      t.string  :label,      null: false
      t.string  :short_label
      t.text    :description
      t.integer :position,   null: false, default: 0
      t.boolean :active,     null: false, default: true
      t.date    :effective_from
      t.date    :effective_to
      t.jsonb   :metadata,   null: false, default: {}
      t.timestamps
    end

    add_index :system_reference_values, :public_id, unique: true
    add_index :system_reference_values, [ :system_reference_list_id, :key ], unique: true, name: "idx_srv_list_key"
    add_index :system_reference_values, [ :system_reference_list_id, :code ], name: "idx_srv_list_code"
    add_index :system_reference_values, :metadata, using: :gin
    add_index :system_reference_values, :parent_id
  end
end

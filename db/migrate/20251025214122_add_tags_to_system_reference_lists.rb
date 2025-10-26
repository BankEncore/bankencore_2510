# db/migrate/20251025220000_add_tags_to_system_reference_lists.rb
class AddTagsToSystemReferenceLists < ActiveRecord::Migration[7.2]
  def change
    add_column :system_reference_lists, :tags, :text, array: true, default: [], null: false
  end
end

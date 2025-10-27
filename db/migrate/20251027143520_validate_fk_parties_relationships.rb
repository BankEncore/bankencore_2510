# db/migrate/20251027143520_validate_fk_parties_relationships.rb
class ValidateFkPartiesRelationships < ActiveRecord::Migration[8.0]
  def change
    validate_foreign_key :parties_relationships, :parties_parties, column: :source_party_id
    validate_foreign_key :parties_relationships, :parties_parties, column: :target_party_id
  end
end

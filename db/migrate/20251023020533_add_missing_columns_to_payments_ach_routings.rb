class AddMissingColumnsToPaymentsAchRoutings < ActiveRecord::Migration[8.0]
  def change
    add_column :payments_ach_routings, :address, :string, limit: 36, comment: "Delivery address"
    add_column :payments_ach_routings, :zip_code, :string, limit: 10, comment: "ZIP code"
    add_column :payments_ach_routings, :phone_number, :string, limit: 20, comment: "Contact phone, digits only"
    add_column :payments_ach_routings, :notes, :text, comment: "Freeform notes"

    add_column :payments_ach_routings, :us_treasury, :boolean, null: false, default: false, comment: "ACH number is U.S. Treasury payment"
    add_column :payments_ach_routings, :us_postal_service, :boolean, null: false, default: false, comment: "ACH number is U.S. Postal Service money order"
    add_column :payments_ach_routings, :federal_reserve_bank, :boolean, null: false, default: false, comment: "Federal Reserve Bank flag"
    add_column :payments_ach_routings, :on_us, :boolean, null: false, default: false, comment: '"On-us" account'
    add_column :payments_ach_routings, :special_handling, :boolean, null: false, default: false, comment: "Docs require special handling"
  end
end

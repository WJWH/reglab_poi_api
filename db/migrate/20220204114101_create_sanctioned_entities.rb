class CreateSanctionedEntities < ActiveRecord::Migration[7.0]
  def change
    enable_extension :pg_trgm

    create_table :sanctioned_entities do |t|
      t.string :full_name, null: false
      t.string :last_name
      t.integer :sdn_id, null: false
      t.string :type, null: false # individual, company or vessel
      t.integer :parent_id
      t.string :sdn_program
      t.string :sdn_type
      t.text :remarks
      t.timestamps

      t.index :full_name, opclass: :gin_trgm_ops, using: :gin
      t.index :last_name, opclass: :gin_trgm_ops, using: :gin
    end
  end
end

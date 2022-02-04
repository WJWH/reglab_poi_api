class CreateSanctionedEntities < ActiveRecord::Migration[7.0]
  def change
    enable_extension :pg_trgm

    create_table :sanctioned_entities do |t|
      t.integer :list_id, null: false
      t.integer :parent_id
      t.string :full_name, null: false
      t.string :entity_type, null: false
      t.string :sanction_program
      t.string :authority
      t.string :title
      t.text :remarks
      t.timestamps

      t.index :full_name, opclass: :gin_trgm_ops, using: :gin
      t.index [:list_id, :authority], unique: true
    end
  end
end

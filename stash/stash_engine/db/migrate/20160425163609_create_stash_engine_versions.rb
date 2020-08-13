class CreateStashEngineVersions < ActiveRecord::Migration[4.2]
  def change
    create_table :stash_engine_versions do |t|
      t.integer :version
      t.string :zip_filename
      t.integer :resource_id

      t.timestamps null: false
    end
  end
end

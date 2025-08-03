class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.integer :match_id
      t.string :name
      #t.datetime :created_at
      #t.datetime :update_at

      t.timestamps
    end
  end
end

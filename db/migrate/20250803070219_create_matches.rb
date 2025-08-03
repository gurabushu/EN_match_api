class CreateMatches < ActiveRecord::Migration[8.0]
  def change
    create_table :matches do |t|
      t.integer :user_id
      t.integer :target_id
      t.boolean :status
      #t.datetime :created_at
      #t.datetime :update_at

      t.timestamps
    end
  end
end

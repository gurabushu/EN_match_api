class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password
      t.string :skill
      t.text :description
      t.datetime :created_at
      t.datetime :update_at

      t.timestamps
    end
  end
end

class AddAgeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :age, :integer
  end
end

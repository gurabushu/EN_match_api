class AddImgToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :img, :string
  end
end

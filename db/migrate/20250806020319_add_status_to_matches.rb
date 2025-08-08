class AddStatusToMatches < ActiveRecord::Migration[8.0]
  def change
    add_column :matches, :status, :boolean
  end
end

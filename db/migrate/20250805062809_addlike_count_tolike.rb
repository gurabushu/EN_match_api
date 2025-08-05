class AddlikeCountTolike < ActiveRecord::Migration[6.1]
  def change
    add_column :likes, :like_count, :integer  # ← :like → :likes に修正
  end
end
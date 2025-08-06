class ChangeDefaultStatusToMatches < ActiveRecord::Migration[8.0]
  def change
    change_column_default :matches, :status, from: nil, to: true
  end
end
# db/migrate/20250806085740_add_default_true_to_status_in_matches.rb

class AddDefaultTrueToStatusInMatches < ActiveRecord::Migration[8.0]
  def change
    change_column_default :matches, :status, from: nil, to: true
  end
end
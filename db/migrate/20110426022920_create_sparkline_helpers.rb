class CreateSparklineHelpers < ActiveRecord::Migration
  def self.up
    create_table :sparkline_helpers do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :sparkline_helpers
  end
end

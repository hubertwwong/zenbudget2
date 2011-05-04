class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books do |t|
      t.decimal :amount
      t.string :description
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :books
  end
end

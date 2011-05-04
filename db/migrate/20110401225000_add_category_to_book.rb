class AddCategoryToBook < ActiveRecord::Migration
  def self.up
      add_column :books, :category_id, :integer
  end

  def self.down
      remove_column :books, :category_id
  end
end

class Category < ActiveRecord::Base
    
  validates_uniqueness_of :name
  
  has_one :book
  
  
  
  # returns the prefix. the stuff before the colon
  def prefix
    if self.name != nil
      self.name.split(':').first
    else
      nil
    end
  end
  
  # returns the suffix. the stuff after the colon.
  def suffix
    if self.name != nil
      self.name.split(':').last
    else
      nil
    end
  end
  
  # determine if the prefix is equal to "income"
  # used for the book model. basically. if its not in the income category,
  # the running total of the books get deducted instead of added to.
  def prefix_is_income?
    if self.name != nil
      self.prefix == "income" && self.prefix != "system"
    else
      nil # returns nil if the object was not initialized correctly.
    end
  end
  
  # returns the row that contains 'system:current income'
  def self.current_income
    Category.find_by_name('system:current income')
  end
  
  # init the database with categories that users can select.
  # crude issue. this won't load in to unit test correctly since that pulls
  # data from the fixtures. need to hard code those seperately.
  def self.db_init
    Category.create(:name => 'income:paycheck')
    Category.create(:name => 'income:misc')
    Category.create(:name => 'bill:utility')
    Category.create(:name => 'bill:credit card')
    Category.create(:name => 'bill:insurance')
    Category.create(:name => 'bill:mortgage')
    Category.create(:name => 'bill:rent')
    Category.create(:name => 'bill:misc')
    Category.create(:name => 'saving:retirement')
    Category.create(:name => 'saving:emergency fund')
    Category.create(:name => 'saving:misc')
    Category.create(:name => 'other:food')
    Category.create(:name => 'other:entertainment')
    Category.create(:name => 'other:food')
    Category.create(:name => 'other:gas')
    Category.create(:name => 'other:misc')
    Category.create(:name => 'system:current income')
  end
    
  # GROUP QUERIES.
  ##############################################################################
    
  # return an arrays of ids with the prefix as income.
  def self.income_ids
    Category.cat_ids('income')  
  end
  
  # return an arrays of ids with the prefix as income.
  def self.bill_ids
    Category.cat_ids('bill')  
  end

  # return an arrays of ids with the prefix as income.
  def self.other_ids
    Category.cat_ids('other')  
  end
  
  # return an arrays of ids with the prefix as income.
  def self.saving_ids
    Category.cat_ids('saving')  
  end


  # return a list of ids with the specified prefix.
  def self.cat_ids(prefix)
    cat_ids = Array.new
    
    # loop through all elements.
    # find ones that have the income prefix and return the ids.
    Category.find_each do |cat_item|
      if cat_item.prefix == prefix
        cat_ids.push(cat_item)
      end
    end
    
    # return ids.
    cat_ids 
  end

end

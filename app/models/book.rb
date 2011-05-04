class Book < ActiveRecord::Base
    
  belongs_to :user
  belongs_to :category



  # a method to compute the running total.
  # this should be called right be before a save event.
  def update_current_income
    current_income = Book.read_current_income(self.user_id)
    
    # determines if the item is a cost or income.
    # make the necessary adjustment and save the result.
    if self.category.prefix_is_income?
      current_income.amount += self.amount
    else
      current_income.amount -= self.amount
    end
    current_income.save
  end

  def alter_current_income(new_income)
    diff_in_income = new_income.to_f - self.amount
    updated_total = Book.read_current_income(self.user_id).amount - diff_in_income
    
    #logger.debug ">==========="
    #logger.debug "new: " + new_income
    #logger.debug "current_total: " + self.amount.to_s
    #logger.debug "category: " + self.category.name.to_s
    #logger.debug "prefix is income? " + self.category.prefix_is_income?.to_s
    #logger.debug "diff income " + diff_in_income.to_s
    #logger.debug "updated_total: " + updated_total.to_s
    #logger.debug "<==========="
    #current_income = self.read_current_income
    
    # determines if the item is a cost or income.
    # make the necessary adjustment and save the result.
    if self.category.prefix_is_income?
      diff_in_income = new_income.to_f - self.amount
      updated_total = self.read_current_income.amount + diff_in_income
      current_income = self.read_current_income
      
      # save the current income.
      current_income.amount = updated_total
      current_income.save
    else
      diff_in_income = new_income.to_f - self.amount
      updated_total = self.read_current_income.amount - diff_in_income
      current_income = self.read_current_income
      
      # save the current income.
      current_income.amount = updated_total
      current_income.save
    end
  end
  
  def delete_current_income
    self.alter_current_income(0.0)
  end

  # returns the row in the db with the current user income.
  # can probably use this to create the db line.
  #def read_current_income
  #  cur_category = Category.current_income
  #  if cur_category != nil
  #    current_income_id = cur_category.id
  #    b = Book.find_by_user_id_and_category_id(self.user_id, current_income_id)
  #    
  #    # if b is nil. create a row and return it.
  #    if b == nil
  #      b = Book.new
  #      b.user_id = self.user_id
  #      b.category_id = current_income_id
  #      b.amount = 0.00
  #      b.description = 'system setting. keeps a running total of this user.'
  #      b.save
  #    else
  #      b
  #    end
  #  else
  #    nil # category db was not init correctly.
  #  end
  #end

  # QUERY METHODS: BASIC
  ######################

  # read all rows by a user except the rows with the system prefix.
  # system prefix rows are not user inputed.
  def self.read_all_except_system(user_id)
    current_income_id = Book.find_by_user_id_and_category_id(user_id, Category.current_income.id)
    books = Book.where("user_id = ? AND id not in (?)", user_id, current_income_id)
    #books.where("id not in (?)", current_income_id)
  end
  
  # read the current running total for this user.
  def self.read_current_income(user_id)
    current_cat = Category.current_income
    b = Book.find_by_user_id_and_category_id(user_id, current_cat.id)
    if b == nil
      Book.init_current_income(user_id)
      b = Book.find_by_user_id_and_category_id(user_id, current_cat.id)
    else
      b
    end
  end
  
  # QUERY METHODS: FOR CHARTS
  ###########################
  
  # read income for the n days.
  def self.read_income(user_id, n_days)
    cat_ids = Category.income_ids
    books_by_user = Book.read_by_category_and_date(user_id, cat_ids, n_days)
  end
  
  # read income for the n days.
  def self.read_bill(user_id, n_days)
    cat_ids = Category.bill_ids
    books_by_user = Book.read_by_category_and_date(user_id, cat_ids, n_days)
  end

  # low level method to read a set of rows based off a user, categories, and a date restriction
  def self.read_by_category_and_date(user_id, cat_ids, n_days)
    books_by_user = Book.where("user_id = ? AND category_id in (?) AND created_at > ?", user_id, cat_ids, n_days.days.ago.to_date)
  end

  # return a array of number representing the spending levels for the last n days
  def self.read_spending_level(user_id, n_days)
    cat_ids = Category.bill_ids
    Book.read_level(user_id, n_days, cat_ids)
  end
  
  # return a array of number representing the spending levels for the last n days
  def self.read_saving_level(user_id, n_days)
    cat_ids = Category.saving_ids
    Book.read_level(user_id, n_days, cat_ids)
  end
  
  # low level method to return any of numbers that represent spending levels.
  # return the values in oldest to newest date in array format.
  def self.read_level(user_id, n_days, cat_ids)
    books_by_user = Book.read_by_category_and_date(user_id, cat_ids, n_days)

    # start with todays date in utc time and walk back n days.
    results = Array.new
    start_date = Time.now.utc.to_date
    end_date = n_days.days.ago.to_date
    start_date.downto(end_date) { |d|
      #puts d.to_date
      rows = Book.where("user_id = ? AND category_id in (?) AND created_at >= (?) AND created_at <= (?)", user_id, cat_ids, d.beginning_of_day, d.end_of_day)
      if rows != nil && rows.size > 0
        #puts "hi"
        results.push(rows.sum("amount").to_f)
        #results.push(rows.first.id)
      else
        #puts "bye"
        results.push(0.0)
      end
    }
    #puts "\n====="
    #puts Book.find_all_by_user_id(user_id).last.amount
    #puts Book.find_all_by_user_id(user_id).last.created_at
    #puts Book.find_all_by_user_id(user_id).last.category.name
    #puts Book.find_all_by_user_id(user_id).first.amount
    #puts Book.find_all_by_user_id(user_id).first.created_at
    #puts Book.find_all_by_user_id(user_id).first.category.name

    # return the results.
    results.reverse
  end

  # COMPUTATION METHODS: FOR CHARTS. 
  ##################################

  # compute percent of money left for some period.
  # basically it makes this computation...
  # (income - cost) / income
  def self.percent_current_income(user_id, n_days)
    current_income = Book.sum_income(user_id, n_days)
    current_cost = Book.sum_bill(user_id, n_days)
    result = (current_income.to_f - current_cost.to_f) / current_income.to_f
  end

  # sum income for the last n days
  def self.sum_income(user_id, n_days)
    books_by_user = Book.read_income(user_id, n_days)
    books_by_user.sum('amount')
  end
  
  # sums bills for the last n days
  def self.sum_bill(user_id, n_days)
    books_by_user = Book.read_bill(user_id, n_days)
    books_by_user.sum('amount')
  end
  
  # INIT METHODS
  ##############
  
  # create a row that keeps a running total.
  def self.init_current_income(user_id)
    # fetch category id for system:current
    cash_category = Category.find_by_name('system:current income')

    # create a book row with the current result..
    b = Book.new
    b.user_id = user_id
    b.amount = 0.0
    b.category_id = cash_category.id
    b.description = 'system setting. do not modify.'
    b.save
  end
  
  # UPDATE MONEY METHODS.
  #######################

  # ADD A BILL to the running total
  def self.add_current_bill(user_id, new_income)
    Book.alter_current_total(user_id, 0.0, new_income.to_f * -1.0)
  end

  # ADD INCOME to the running total
  def self.add_current_income(user_id, new_income)
    Book.alter_current_total(user_id, 0.0, new_income)
  end

  # update the running total by user editing a bill item.
  def self.update_current_bill(user_id, old_income, new_income)
    Book.alter_current_total(user_id, old_income.to_f * -1.0, new_income.to_f * -1.0)
  end

  # update the running total by user editing a income item.
  def self.update_current_income(user_id, old_income, new_income)
    Book.alter_current_total(user_id, old_income, new_income)
  end

  # update the running total. user deleted a bill row.
  def self.delete_current_bill(user_id, old_income)
    Book.alter_current_total(user_id, old_income.to_f * -1.0, 0.0)
  end

  # update the running total. user deleted a income row.
  def self.delete_current_income(user_id, old_income)
    Book.alter_current_total(user_id, old_income, 0.0)
  end

  # ALTER CURRENT MONEY.
  def self.alter_current_total(user_id, old_income, new_income)
    current_income = Book.read_current_income(user_id)
    current_income.amount += new_income.to_f - old_income.to_f
    current_income.save
  end

end

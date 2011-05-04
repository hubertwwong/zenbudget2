require 'test_helper'

class BookTest < ActiveSupport::TestCase
  
  test "read current income function" do
    b = Book.new
    
    # nothing in db.
    # assert_nil b.read_current_income
    
    u = users(:user_01)
    
    # load categories of interest for this test case.
    c_income = Category.find_by_name('income:misc')
    c_bill = Category.find_by_name('bill:misc')
    
    # create some dummy book data
    Book.create(:user_id => u.id, :category_id => c_income.id, :amount => 1000.00, :description => 'income')
    Book.create(:user_id => u.id, :category_id => c_bill.id, :amount => 50.00, :description => 'other bill')
    
    # load some line from the db.
    b_other = Book.find_by_category_id(c_bill.id)
    assert_not_nil b_other
    
    # init the running total line from the db.
    Book.init_current_income(u.id)
    
    # running total should be 5
    assert_equal 13, u.books.size
    
    # checks to see if newly inserted thing.
    assert_equal 19, Category.all.size
    assert_equal 50.0, b_other.amount.to_f
    assert_equal 3550.0, Book.read_current_income(u.id).amount.to_f
  end
 
  # stuck on this part.
  # not sure what....
  test "update current income function" do
    b = Book.new
    
    u = users(:user_01)
  
    # Category.db_init
    c = Category.current_income
    c_other = Category.find_by_name('bill:credit card')
    Book.create(:user_id => u.id, :category_id => c.id, :amount => 1000.00, :description => 'income')
    b_other = Book.create(:user_id => u.id, :category_id => c_other.id, :amount => 50.00, :description => 'other bill')
    b_other.update_current_income
    
    # checks to see if newly inserted thing.
    assert_equal 3500.0, Book.read_current_income(u.id).amount.to_f
  end
  
  # stuck on this part.
  # not sure what....
  test "update some income" do
    b = Book.new
    
    u = users(:user_01)
      
    # init the system count.
    Book.init_current_income(u.id)
    
    # check to see if system item is there.
    current_income = Book.read_current_income(u.id)
    assert_not_nil current_income
    assert_equal 3550.0, current_income.amount.to_f
  
    # Category.db_init
    c = Category.current_income
    b = Book.create(:user_id => u.id, :category_id => c.id, :amount => 1000.00, :description => 'income')
    
    # Update total.
    Book.add_current_income(u.id, 1000.00)
    
    # checks to see if newly inserted thing.
    assert_equal 4550.0, Book.read_current_income(u.id).amount.to_f
    
    # initial assignments.
    b = books(:user_01_gas)
    Book.add_current_bill(u.id, b.amount)
    
    assert_equal "4500.0", Book.read_current_income(u.id).amount.to_s
  end
  
  test "accessing users book rows using accessor functions." do
    b = Book.new
    
    # create some dummy data.
    # have to manually create the income line.
    u = users(:user_01)
    
    # init the system count.
    Book.init_current_income(u.id)
  
    # adding a row to the books. there should be 2 things in there now.
    c = Category.current_income
    b = Book.create(:user_id => u.id, :category_id => c.id, :amount => 1000.00, :description => 'income')
    
    # 2 things are in the books rows. 1 is entered by the user.
    user_books = Book.read_all_except_system(u.id)
    assert_equal 12, u.books.size
    assert_equal 11, user_books.size
    assert_not_nil Book.read_current_income(u.id)
  end
  
  test "testing self methods. delete me.." do
    u = users(:user_01)
    
    # init the system count.
    Book.init_current_income(u.id)
    assert_not_nil Book.read_current_income(u.id)
  end
  
  test "testing update user total methods." do
    u = users(:user_01)
    
    # init the system count.
    Book.init_current_income(u.id)
    assert_not_nil Book.read_current_income(u.id)
    
    # baseline.
    Book.add_current_income(u.id, 1000.0)
    b = Book.read_current_income(u.id)
    assert_equal 4550.0, b.amount.to_f
    
    # adding some bill
    Book.add_current_bill(u.id, 100.0)
    b = Book.read_current_income(u.id)
    assert_equal 4450.0, b.amount.to_f
    
    # update income from 1000 to 1100
    Book.update_current_income(u.id, 1000.0, 1100.0)
    b = Book.read_current_income(u.id)
    assert_equal 4550.0, b.amount.to_f
    
    # update a bill from 100 to 200
    Book.update_current_bill(u.id, 100.0, 200.0)
    b = Book.read_current_income(u.id)
    assert_equal 4450.0, b.amount.to_f
    
    # delete the 200 bill
    Book.delete_current_bill(u.id, 200.0)
    b = Book.read_current_income(u.id)
    assert_equal 4650.0, b.amount.to_f
    
    # delete the income.
    Book.delete_current_income(u.id, 1100.0)
    b = Book.read_current_income(u.id)
    assert_equal 3550.0, b.amount.to_f
    
  end
  
  test "read income for n days" do
    u = users(:user_01)
    
    # query
    results = Book.read_income(u.id, 32)
    
    # testing results. threre should be 4. you can check the fixtures for this.
    assert_equal 1, results.size

    # checking the oldest elements. it should be a paycheck about 4 months old.
    # using the to_date function to only look at the date.
    #assert_equal 'income:paycheck', results.first.category.name
    #assert_equal 1000.0, results.first.amount
    #assert_equal 4.month.ago.to_date, results.first.created_at.to_date

    assert_equal 'income:paycheck', results.last.category.name
    assert_equal 1000.0, results.last.amount
    assert_equal 1.month.ago.to_date, results.last.created_at.to_date
  end
  
  test "read bill for n days" do
    u = users(:user_01)
    
    # query
    results = Book.read_bill(u.id, 63)
    
    # testing results. threre should be 2. you can check the fixtures for this.
    assert_equal 2, results.size

    # checking the oldest elements. it should be a paycheck about 4 months old.
    # using the to_date function to only look at the date.
    assert_equal 'bill:credit card', results.first.category.name
    assert_equal 100.0, results.first.amount
    assert_equal 2.month.ago.to_date, results.first.created_at.to_date

    assert_equal 'bill:credit card', results.last.category.name
    assert_equal 100.00, results.last.amount
    assert_equal 1.month.ago.to_date, results.last.created_at.to_date
  end
  
  test "sum income for n days" do
    u = users(:user_01)
    
    # query
    results = Book.read_income(u.id, 64)
    
    # testing results. threre should be 4. you can check the fixtures for this.
    assert_equal 2, results.size

    # checking amount of income. 2 * 1000.0 = 2000.0 for 2 paychecks. check fixtures for this.
    results = Book.sum_income(u.id, 64)
    assert_equal 2000.0, results
  end

  test "sum bill for n days" do
    u = users(:user_01)
    
    # query
    results = Book.read_bill(u.id, 64)
    
    # testing results. threre should be 4. you can check the fixtures for this.
    assert_equal 2, results.size

    # checking amount of income. 2 * 100.0 = 200.0 for 2 paychecks. 
    # check fixtures for this.
    results = Book.sum_bill(u.id, 64)
    assert_equal 200.0, results
  end

  test "percent total for last n days" do
    u = users(:user_01)
    
    # query
    results = Book.read_bill(u.id, 64)
    
    # testing results. threre should be 4. you can check the fixtures for this.
    assert_equal 2, results.size

    # percent totals. 100 / 1000 = 10%
    result = Book.percent_current_income(u.id, 64)
    assert_equal 0.9, result
  end

  test "spending level array of numbers" do
    u = users(:user_03)

    # spending levels... in array form. there should be a bunch of zero values
    # and 10.0 for the last day.
    result = Book.read_spending_level(u.id, 32)
    assert_not_nil result.to_s
    assert_equal 0.0, result[0]
    assert_equal 0.0, result[1]
    assert_equal 0.0, result[2]
    assert_equal 0.0, result[30]
    assert_equal 0.0, result[31]
    assert_equal 10.0, result[32]
  end
  
  test "saving level array of numbers" do
    u = users(:user_03)

    # spending levels... in array form. there should be a bunch of zero values
    # and 10.0 for the last day.
    result = Book.read_saving_level(u.id, 32)
    assert_not_nil result.to_s
    assert_equal 0.0, result[0]
    assert_equal 0.0, result[1]
    assert_equal 0.0, result[2]
    assert_equal 0.0, result[30]
    assert_equal 0.0, result[31]
    assert_equal 100.0, result[32]
  end

end

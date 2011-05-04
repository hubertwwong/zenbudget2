require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
    
  test "prefix function" do
    c = Category.new
    c.name = 'income:paycheck'
    assert_equal 'income', c.prefix
  end
  
  test "suffix function" do
    c = Category.new
    c.name = 'income:paycheck'
    assert_equal 'paycheck', c.suffix
  end
  
  test "prefix is income function" do
    c = Category.new
      
    # no objects in db.. should return nil.
    assert_equal nil, c.prefix_is_income?
      
    # insert item into db with the correct prefix.
    Category.create(:name => 'income:misc')
      
    # load a correct category.
    c.name = 'income:misc'
      
    # income:misc should be true.
    assert_equal true, c.prefix_is_income?
      
    # load an incorrect category.
    c.name = 'other:misc'
      
    # other:misc should be false.
    assert_equal false, c.prefix_is_income?
  end
  
  test "income prefix function" do
    results = Category.income_ids
    
    assert_equal 2, results.size
  end
  
end

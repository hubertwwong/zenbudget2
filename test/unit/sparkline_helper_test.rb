require 'test_helper'

class SparklineHelperTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

  test "convert to str helper method" do
    # create a array of numbers.
    nums1 = [2.2, 3.3, 4]
    nums2 = [2.0]
    
    result1 = SparklineHelper.convert_to_str(nums1)
    assert_equal '[2.2, 3.3, 4]', result1
    result2 = SparklineHelper.convert_to_str(nums2)
    assert_equal '[2.0]', result2
  end

end

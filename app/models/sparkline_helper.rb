# simple helper methods to allow the models output in the format needed
# for sparklines.
# class might be obsolete. just occured to me you can use the to_s method.
class SparklineHelper < ActiveRecord::Base

  # converts an array of num to the 
  def self.convert_to_str(nums)
    # prefix.
    result = '['
    
    # loop through array of numbers and append them over to the string.
    # first element needs to be check so you don't put a comma in front
    # of the first element.
    nums.each_with_index do |item, i|
      if i == 0 
        result = result + item.to_s
      else
        result = result + ', ' + item.to_s
      end
    end
    
    # suffix.
    result = result + ']'
  end

end

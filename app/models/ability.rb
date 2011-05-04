class Ability
    
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    
    # manage user permissions.
    # only have one user type at this point.
    if user != nil
      can :create, Book
      can [:read, :update, :destroy], Book do |book|
        book.try(:user) == user
      end
    end
  end
  
end

require 'test_helper'

class BooksControllerTest < ActionController::TestCase
  # devise test helper. this allows you to have users.
  include Devise::TestHelpers

  setup do
    @book = books(:one)
  end

  test "should get index" do
    sign_in users(:user_01)          # sign_in(resource)
      
    get :index
    assert_response :success
    assert_not_nil assigns(:books)
  end

  test "should get new" do
    sign_in users(:user_01)          # sign_in(resource)
      
    get :new
    assert_response :success
  end

  test "should create book" do
    sign_in users(:user_01)          # sign_in(resource)  
    
    assert_difference('Book.count') do
      post :create, :book => @book.attributes
    end

    assert_redirected_to book_path(assigns(:book))
  end

  test "should show book" do
    sign_in users(:user_01)          # sign_in(resource)  
      
    get :show, :id => @book.to_param
    assert_response :success
  end

  test "should get edit" do
    sign_in users(:user_01)          # sign_in(resource)
    
    get :edit, :id => @book.to_param
    assert_response :success
  end

  test "should update book" do
    sign_in users(:user_01)          # sign_in(resource)  
      
    put :update, :id => @book.to_param, :book => @book.attributes
    assert_redirected_to book_path(assigns(:book))
  end

  test "should destroy book" do
    sign_in users(:user_01)          # sign_in(resource)
    
    assert_difference('Book.count', -1) do
      delete :destroy, :id => @book.to_param
    end

    assert_redirected_to books_path
  end
end

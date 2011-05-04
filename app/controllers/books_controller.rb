class BooksController < ApplicationController

  # cancan shortcut for rest resource
  load_and_authorize_resource

  # GET /books
  # GET /books.xml
  def index
    @books = Book.read_all_except_system(current_user.id).page(params[:page]).per(10)
    @current_total = Book.read_current_income(current_user.id)
    
    # new stuff.
    @percent_current_income = Book.percent_current_income(current_user.id, 31)
    @spending_levels = Book.read_spending_level(current_user.id, 31)
    @sum_income = Book.sum_income(current_user.id, 31).to_f
    @sum_bill = Book.sum_bill(current_user.id, 31).to_f

    # new book.
    @book = Book.new
    @book.user_id = current_user.id

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @books }
    end
  end

  # GET /books/1
  # GET /books/1.xml
  def show
    @book = Book.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @book }
    end
  end

  # GET /books/new
  # GET /books/new.xml
  def new 
    @book = Book.new
    @book.user_id = current_user.id

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @book }
    end
  end

  # GET /books/1/edit
  def edit
    @book = Book.find(params[:id])
  end

  # POST /books
  # POST /books.xml
  def create
    @book = Book.new(params[:book])
    @book.user_id = current_user.id

    # figure out if the item entered if a bill or income.
    # if its a bill. change the value so its neatige.
    if @book.category.prefix_is_income?
      Book.add_current_income(current_user.id, @book.amount)
    else
      Book.add_current_bill(current_user.id, @book.amount)
    end

    # updates the running total.
    # @book.update_current_income
    # above line is still in testing.

    respond_to do |format|
      if @book.save
        format.html { redirect_to(@book, :notice => 'Book was successfully created.') }
        format.xml  { render :xml => @book, :status => :created, :location => @book }
        format.js {
          # reload index data again. this is called from the index.html.erb
          @books = Book.read_all_except_system(current_user.id)
          @current_total = Book.read_current_income(current_user.id)
        }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @book.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  # PUT /books/1
  # PUT /books/1.xml
  def update
    @book = Book.find(params[:id])

    # figure out if the item entered if a bill or income.
    # if its a bill. change the value so its neatige.
    if @book.category.prefix_is_income?
      Book.update_current_income(current_user.id, @book.amount, params[:book][:amount])
    else
      Book.update_current_bill(current_user.id, @book.amount, params[:book][:amount])
    end
    
    respond_to do |format|
      if @book.update_attributes(params[:book])
        format.html { redirect_to(@book, :notice => 'Book was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @book.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1
  # DELETE /books/1.xml
  def destroy
    @book = Book.find(params[:id])
    
    # update the running total. 
    if @book.category.prefix_is_income?
      Book.delete_current_income(current_user.id, @book.amount)
    else
      Book.delete_current_bill(current_user.id, @book.amount)
    end
    
    # @book.delete_current_income
    @book.destroy

    respond_to do |format|
      format.html { redirect_to(books_url) }
      format.xml  { head :ok }
    end
  end

end

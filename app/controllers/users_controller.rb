class UsersController < ApplicationController
  
  before_action :authenticate_user, {only: [:index, :show, :edit, :update]}
  # before_actionにforbid_login_userメソッドを指定してください
  before_action :forbid_login_user, {only: [:new, :create, :login_form, :login]}
  before_action :eusure_correct_user, {only: [:edit, :update]}
  
  def index
    @users = User.all
  end
  
  def show
    @user = User.find_by(id: params[:id])
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(
      name: params[:name],
      email: params[:email],
      password: params[:password],
      image_name: "default_user.jpg"
      )
      
    if @user.save
      flash[:notice] = "ユーザー登録が完了しました"
      session[:user_id] = @user.id
      redirect_to("/users/#{@user.id}")
    else
      render("/users/new")
    end
  end
  
  def edit
    @user = User.find_by(id: params[:id])
  end 
  
  def update
    @user = User.find_by(id: params[:id])
    @user.name = params[:name]
    @user.email = params[:email]
    
    # 画像を保存する処理を追加してください
    if params[:image]
      @user.image_name = "#{@user.id}.jpg"
      image = params[:image]
      #logger.debug(image.inspect)
      # File.binwrite("public/user_images/#{@user.image_name}", image.read)
     
      picname = "public/user_images/#{@user.image_name}"
      File.open(picname,"wb") do |file|
        file.puts image.read
      end
      
    end
    
    if @user.save
      flash[:notice] = "ユーザー情報を編集しました"
      redirect_to("/users/#{@user.id}")
    else
      render("users/edit")
    end
  end
  
  def login_form
  end
  
  def login
    @user = User.find_by(email: params[:email],
                         password: params[:password]
                         )
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id

      flash[:notice] = "ログインしました"
      redirect_to("/posts/index")
    else
      @error_message = "メールアドレスまたはパスワードが間違っています"
      @email = params[:email]
      @password = params[:password]
      render("users/login_form")
    end
  end
  
  def logout
    session[:user_id] = nil
    flash[:notice] = "ログアウトしました"
    redirect_to("/login")
  end
  
  def likes
    @user = User.find_by(id: params[:id])
    @likes = Like.where(user_id: @user.id)
  end
  
  def eusure_correct_user
    if @current_user.id != params[:id].to_i
      flash[:notice] = "権限がありません"
      redirect_to("/users/index")
    end
  end
  
  
end

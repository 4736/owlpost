class PostsController < ApplicationController
  before_action :authenticate_user!
  around_filter :record_not_found

  def new
    @post = current_user.posts.new
  end

  def create
    @post = current_user.posts.new( posts_params )
    if @post.save
      @post.delay(run_at: @post.eta, owner_type: "post", owner_id: @post.id).deliver
      redirect_to posts_path, :flash => { :notice => "Post Created." }
    else
      render :new
    end
  end

  def update
    @post = current_user.posts.find(params[:id])
    if @post.update( posts_params )

      job = Delayed::Job.find_by_owner_type_and_owner_id!("post", @post.id)
      job.update( run_at: @post.eta )

      redirect_to posts_path, :flash => { :notice => "Post Updated." }
    else
      render :new
    end
  end

  def edit
    @post = current_user.posts.find(params[:id])
  end

  def destroy
    post = current_user.posts.find(params[:id])
    Delayed::Job.find_by_owner_type_and_owner_id!("post", post.id).destroy
    post.destroy
    redirect_to posts_path
  end

  def index
    @posts = current_user.posts
  end

  def show
    redirect_to edit_post_path(params[:id])
  end

  private
  def posts_params
    parameters = params.require(:post).permit(:eta, :sender, :recipients, :subject, :body)
    # replaces blank eta field with current time
    parameters[:eta] = (parameters[:eta] == "" ? Time.zone.now : parameters[:eta])
    # splits emails by comma
    parameters[:recipients] = parameters[:recipients].split(',').map(&:strip)
    parameters
  end

  # redirects if no record is found.
  # The purpose of this is i can use current_user and this method to prevent users from trying to view posts...
  # that ar'nt theirs rather than wrapping crequests in an if else. Its just pretty this way
  def record_not_found
    yield
  rescue ActiveRecord::RecordNotFound
    redirect_to posts_path, :flash => { :alert => "Record not found." }
  end
end

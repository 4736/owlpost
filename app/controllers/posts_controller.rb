class PostsController < ApplicationController
  before_action :authenticate_user!
  around_filter :record_not_found

  def new
    @post = current_user.posts.new
  end

  def create
    post = current_user.posts.create( posts_params )
    post.delay(run_at: post.eta, owner_type: "post", owner_id: post.id).deliver

    redirect_to posts_path
  end

  def update
    post = current_user.posts.find(params[:id])
    eta_changed = (posts_params["eta"] != post.eta) ? true : false
    post.update( posts_params )

    # No need to call db an extra time if nothing has changed.
    if eta_changed
      job = Delayed::Job.find_by_owner_type_and_owner_id!("post", post.id)
      job.update( run_at: post.eta )
    end

    redirect_to posts_path
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
    parameters[:eta] = parameters[:eta].to_datetime
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

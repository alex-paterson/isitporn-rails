class PostsController < ApplicationController
  before_action :set_post, only: [:show]

  # GET /posts/1
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # POST /posts
  def create
    Indico.api_key = ENV["INDICO_KEY"]
    chance = Indico.content_filtering(Base64.encode64(post_params[:picture].read))

    @post = Post.new()
    @post.chance = chance
    @post.picture = post_params[:picture]

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:picture, :chance)
    end
end

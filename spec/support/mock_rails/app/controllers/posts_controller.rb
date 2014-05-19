class PostsController < ApplicationController
  def index
    @posts = []
  end

  def new
    @post = Post.new
  end

  def wizard
    @post = Post.new
  end
end

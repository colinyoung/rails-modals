require 'active_hash'

class Post < ActiveHash::Base
  field :title
  field :content
end

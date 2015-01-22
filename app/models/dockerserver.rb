class Dockerserver < ActiveRecord::Base
  has_many :images
  has_many :rundockerservers
end

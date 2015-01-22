class Rundockerserver < ActiveRecord::Base
  belongs_to :run
  belongs_to :dockerserver
  belongs_to :image
end

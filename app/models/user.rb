class User < ActiveRecord::Base

  belongs_to :page

  validates :name, presence: true

end

class Post < ActiveRecord::Base
  before_validation do
    self.sha = calculate_sha
    self.short_sha = sha.first(8)
  end

  validates :body,
    presence: true

  validates :sha, :short_sha,
    presence: true,
    uniqueness: true

  belongs_to :parent,
    class_name: 'Post',
    foreign_key: 'parent_sha',
    primary_key: 'sha'

  has_many :children,
    class_name: 'Post',
    foreign_key: 'parent_sha',
    primary_key: 'sha'


  def calculate_sha
    Digest::SHA1.hexdigest(body)
  end

  def to_param
    short_sha
  end
end

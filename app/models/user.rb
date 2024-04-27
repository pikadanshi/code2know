class User < ApplicationRecord
  include ActiveModel::Dirty
  define_attribute_methods
  
  belongs_to :rank
  belongs_to :role
  has_many :questions
  
  has_secure_password

  after_initialize :default_values, unless: :persisted?

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, length: { maximum: 20 }
  validates :password, on: [:update, :create] ,length: { in: 8..150 }, if: :password_digest_changed?
  validates :xp, numericality: { only_integer: true }
  validates :xp, comparison: { less_than: 9223372036854775808 }


  before_save :level_up #, if: :xp_changed?
  

  private

  def default_values
    self.role ||= Role.find_by(permission: 1)
    self.rank ||= Rank.find_by(level: 1)
    self.xp   ||= 0
  end

  def level_up
    
    while self.rank.threshold > 0 && self.xp >= self.rank.threshold
      self.xp -= self.rank.threshold
      self.rank = Rank.find_by(level: self.rank.level + 1)
    end
  end
  
end

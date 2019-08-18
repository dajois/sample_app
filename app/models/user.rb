class User < ApplicationRecord
  attr_accessor :remember_token
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }

  class << self
    #渡された文字列のハッシュを返す
    def digest(string)
	  	cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                               BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    #ランダムなトークンを返す
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  #永続セッションのためにデータベースに記憶する
  def remember
    self.remember_token = User.new_token        #記憶トークンをremember_tokenに代入
    update_attribute(:remember_digest, User.digest(remember_token)) #DBのremember_token属性値をBcryptに渡してハッシュ化して更新
  end

  #渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  #ユーザのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end
end

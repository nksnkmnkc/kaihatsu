class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :book_comments, dependent: :destroy

  # フォローをした、されたの関係(子要素)
  #フォローする側のUserから見て、フォローされる側のUserを(Relationshipを経由して)集める。なのでfollower_id(フォローする側)
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  #フォローされる側のUserから見て、フォローしてくる側のUserを(Relationship経由で)集める。なのでfollowed_id(フォローされる側)
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy

  # 一覧画面で使う（孫要素）
  # Relationship（passive_relationshipsを経由して「follower」モデルのUser(フォローする側)を集めることを「followers」と定義。自分をフォローしてくれている相手を取得する。相手がフォロワー。フォーリンキーはfollowed.孫要素→follower
  has_many :followers, through: :passive_relationships, source: :follower
  # Relationship（active_relationshipsを経由して「followed」モデルのUser(フォローされた側)を集めることを「followings」と定義。 自分がフォローしている相手を取得する。自分がフォロワー。フォーリンキーはfollower。孫要素はどこから取得するのか→followed
  has_many :followings, through: :active_relationships, source: :followed

  has_one_attached :profile_image

  validates :name, length: { minimum: 2, maximum: 20 }, uniqueness: true
  validates :introduction, length: {maximum: 50 }



  def get_profile_image
    (profile_image.attached?) ? profile_image : 'no_image.jpg'
  end

  # フォローしたときの処理
  def follow(user_id)
   active_relationships.create(followed_id: user_id)
  end
  # フォローを外すときの処理
  def unfollow(user_id)
   active_relationships.find_by(followed_id: user_id).destroy
  end
  # フォローしているか判定
  def following?(user)
   followings.include?(user)
  end

  # 検索方法分岐        完全一致以外の検索方法は、#{word}の前後(もしくは両方に)、__%__を追記することで定義することができる。 where(カラム名: "検索したい文字列")
  def self.looks(search,word)
    if search == "perfect_match"
      @user = User.where("name LIKE?", "#{word}")
    elsif search == "forward_match"
      @user = User.where("name LIKE?", "#{word}%")
    elsif search == "backward_match"
      @user = User.where("name LIKE?", "%#{word}")
    elsif search == "partial_match"
      @user = User.where("name LIKE?", "%#{word}%")
    else
      @user = User.all
    end
  end

end

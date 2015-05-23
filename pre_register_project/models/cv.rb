class Cv
  
  ### Class to model the curriculum vitae of a user.
  ### As it may be subject to some changes and has many different elements
  ### per user, using a non SQL approach seems best for this use case
  ### Also just an excerpt...
  
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Token

  # sidebar has to be skipped, not supported for Mongo documents
  before_filter { @skip_sidebar = true }
  
  field :user_id, type: Integer
  index({ user_id: 1 }, { unique: true })
  
  # personal data, every user has this element
  has_one :personal, dependent: :destroy, autobuild: true
  
  # employers are independent objects for our business case
  has_many :employers
  
  # More information per user
  embeds_many :job_experiences
  embeds_many :foreign_experiences
  field :foreign_exp, type: Boolean
  field :foreign_exp_total, type: Integer
  
  # We want some info about his/her study subjects if applicable
  has_many :studies 
  field :main_studies_degree 
  field :main_studies_focus
  
  # Also he / she might provide some highlights
  validates_length_of :highlights, maximum: 1024
  field :highlights
  
  
  accepts_nested_attributes_for :personal, reject_if: :all_blank, update_only: true
  
  # Using whitelisting instead of blacklisting is better here for MongoDB, as some elements are dynamic and therefore shouldn't be mass assigned...
  attr_accessible
  
  def user
    @user ||= User.where(:user_id => self.id).first
  end
  
  # To make sure we always have up to date info, and the child elements
  # get new timestamps as well, we have to use model.touch, see user 
  # model... this is cascading...
  
  token length: 8
  
  
  #.....#
end

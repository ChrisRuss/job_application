class User < ActiveRecord::Base
  rolify

  # Important: invitable is additional gem and overrides some devise hooks, include in the end.
    devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable, :confirmable, :invitable

  # Setup accessible (or protected) attributes, mass assignement only as admin...
  attr_accessible :role_ids, :as => :admin
  attr_accessible :email, :password, :password_confirmation, :opt_in
  
  validates :email, change: { with: false }, on: :update
  
  #used only as flag
  attr_accessor :invite_mail, :invitermail
  
  # theoretically we allow to track more than just one invitation
  has_many :invitations, :class_name => self.to_s, :as => :invited_by
  
  # We send a mail to show we received the invitation request
  after_create :send_invitreq_received, :assign_initial_role
  
  after_invitation_accepted :email_welcome
  
  ## We instantly create a document for the CV as every user has one
  def cv
     @cv ||= (Cv.where(:user_id => self.id).first || Cv.create(:user_id => self.id))
  end
  
  # Callback hook for :invitable
  def after_invitation_accepted
    email_welcome
  end
  
  
  # We don't need a password on profile creation, will be set on confirmtion
  validates_confirmation_of :password
  def password_required?
    if !persisted?
      !(password != "")
    else
      !password.nil? || !password_confirmation.nil?
    end
    
    # In Devise-Wiki they recommend:
    # super if confirmed?
    # But doesn't work on :invitable as it just would allow an empty 
    # password. But we want to force a password on confirmation...
  end
  
  # override Devise method
  # We don't want usual devise confirmation, handling by using ivitation 
  # and confirmation
  def confirmation_required?
    false
  end

  # override Devise method to reflect our desired behavior
  def active_for_authentication?
    # Allow login just if invited and confirmed
    super && (confirmed? || confirmation_period_valid?) && (self.invitation_accepted?)
  end
  
  # Override method to allow admin unlimited invitations
  def has_invitations_left?
    (self.has_role?(:admin)) ? true : super
  end
  
  # ! because method calls save method...
  def make_vip!
    self.add_role :VIP
    self.invitation_limit = 10
    self.save
  end
  
  def invites_left
    self.invitation_limit
  end
  
  ## Using cancan for our user...
  def ability
    @ability ||= Ability.new(self)
  end
  
  
   #### Override so users can be invited again but don't send invite if already activated 
   ### Returns instance of invited user afterwards
  def self.invite!(attributes={}, invited_by=nil, &block)
    # need to set this variable as it might be used in "super" call
    invite_key_array = [:email]
    mail = attributes[:email].to_s.strip
    
    # Find user if already requested invitation
    invitable = User.where(:email => mail).first
    
    # If there is no user, use "parent" method
    if invitable.blank? || (invitable.invited_to_sign_up?)
      super
    elsif invitable.invitation_accepted?
      # Has already accepted? simulate as if invitation has been sent now
      # (Secret mode...)
      invitable
    else
      invitable.invite!(invited_by)
      invitable
    end

  end
  
  
  def already_waiting_mail
    # we want to avoid spam, so only send mail again if user requested 
    # invitation again AFTER 4 hours
    unless self.updated_at > 4.hours.ago
      self.touch
      UserMailer.already_waiting(self).deliver
    end
  end
  
  
  def already_active_user_mail
    unless self.updated_at > 4.hours.ago
      self.touch
      UserMailer.already_active_user(self).deliver
    end
  end  
  
  
  # re_invite gets called only when not activated but already invited
  # gets checked with invited_to_sign_up call...
  def re_invite!(by_who, invited_by=nil)
    # only resend invitation if already invited, has requested an invitation more than 4 hours ago and was invited at least 1 hour ago
    if (self.invited_to_sign_up?) && (self.updated_at < 4.hours.ago || self.invitation_sent_at < 1.hours.ago)
      if by_who == :selfrequest
        self.invite_mail = :resend_invite
      elsif by_who == :inviter
        self.invite_mail = :reinvite_mail
      end
      if invited_by.blank?
        self.invite!
      else
        self.invite!(invited_by)
      end
    end
    self
  end
  
  
  def deliver_invitation
   if @invite_mail
     ::Devise.mailer.send(@invite_mail, self).deliver
   else
     super
   end
  end
  
  
  # Method to force user activation
  def admin_force_activate!
    pass = Devise.friendly_token.first(8)
    self.reset_password!(pass, pass)
    self.accept_invitation
    self.confirm!
    # accept_invitation doesn't send mail, so send now...
    if self.errors.empty?
      UserMailer.welcome_with_pass(self, pass).deliver
    end
    self
  end
  
  private
  
  # every user will be assigned this initial role.
  def assign_initial_role
    self.add_role :user
  end
  
  # 
  def send_invitreq_received
    # only send "request received" if not invited already and not our admin mail
    unless self.invited_to_sign_up? || self.email.include?('[ADMINMAIL@XXX]') && Rails.env != 'test'
      UserMailer.invitation_request_reply(self).deliver
    end
  end
  
  def email_welcome
    UserMailer.welcome(self).deliver
  end
  
end

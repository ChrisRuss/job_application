class BetaDevise::InvitationsController < Devise::InvitationsController
  
  ### The following changes have been done:
  ## a) Check if a user was already invited. If yes: resend invitation. Set
  ## new referrer as current invitation sender (to track referral)
  ## b) using invitermail as attribute sets referring person and will be
  ## set on activation.
  
  # Create has to be overridden, as I want to check if someone was already
  # invited before...
  def create
    
    # look if user is already in database
    to_invite = resource_class.to_adapter.find_first(email: resource_params[:email])
    
    # if user doesn't exist or hasn't received an invitation yet: send via 
    # regular User.invite! Otherwise: use re_invite! (fat model...)
    self.resource =  to_invite.blank? || !(to_invite.invited_to_sign_up?) ? resource_class.invite!(resource_params, current_inviter) : to_invite.re_invite!(:inviter, current_inviter)
    
    # Now check if received some errors from model...    
    if resource.errors.empty?
      set_flash_message :notice, :send_instructions, :email => self.resource.email
      respond_with resource, :location => after_invite_path_for(resource)
    else
      respond_with_navigational(resource) { render :new }
    end
  end
  
  # as build happens through devise in before filter, only set
  # the parameter and then call and render with super
  def edit
    resource.invitermail = params[:invitermail]
    super
  end
  
  ## As there is an inviting person to set, override update
  def update
    inviter_mail = resource_params.delete "invitermail"
    
    accepted_inviter = resource_class.to_adapter.find_first(email: inviter_mail)
    
    # before inviting person gets credit for the new user: check if he is
    # really allowed to claim. Only certain vip users are allowed...
    if accepted_inviter && accepted_inviter.ability.can?(:invite, resource_class)
      self.resource = resource_class.accept_invitation!(resource_params) 
      resource.invited_by = accepted_inviter
    else
      ## No discussion. User didn't have the right to invite, so show...
      flash[:error] = I18n.t("devise.invitations.no_authorized_inviter")
      raise CanCan::AccessDenied
    end

    if resource.errors.empty?
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active                                                                                        
      set_flash_message :notice, flash_message
      sign_in(resource_name, resource)
      respond_with resource, :location => after_accept_path_for(resource)
    else
      respond_with_navigational(resource){ render :edit }
    end
  end
  
  
  protected
  
  # check if user is allowed to invite (VIP-user)
  def authenticate_inviter!
    if cannot?( :invite, User )
      raise CanCan::AccessDenied
    else
      current_user
    end
  end

end
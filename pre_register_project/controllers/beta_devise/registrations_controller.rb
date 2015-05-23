class BetaDevise::RegistrationsController < Devise::RegistrationsController
  respond_to :html, :js
  
  def new
    flash[:info] = t("beta_state.not_yet_open")
    super
  end

  # As we are in "super suspicious mode", noone should be able to
  # draw a conclusion whether someone is already on the waiting list or 
  # not... As user is identified by email, user always gets notified via 
  # email, not with an imeediate feedback...
  # Also make sure if user requests an invitation and has already been
  # invited, resend activation link
  # See create.js.haml to see JS response if JS is enabled
  def create
    build_resource(sign_up_params)
        if resource.save
          expire_session_data_after_sign_in!
          respond_with resource, :location => after_inactive_sign_up_path_for(resource)
        else
          clean_up_passwords resource
          if resource.errors[:email].include?(I18n.t("errors.messages.taken"))
            user = User.where(email: resource.email).first
            if user.active_for_authentication?
              # Send mail that already registered and ready to log in
              user.already_active_user_mail
            elsif user.invitation_token.nil?
              # Is not invited yet? tell him that he is already on the
              # waiting list
              user.already_waiting_mail
            else
              # Probably didn't get the invitation mail. Resend!
              user.re_invite!(:selfrequest)
            end
            resource.errors.clear
          end
          respond_with resource, :location => after_inactive_sign_up_path_for(resource)
        end
  end
      
  
  protected

  def after_inactive_sign_up_path_for(resource)
    "/thankyou.html"
  end
  
  
end
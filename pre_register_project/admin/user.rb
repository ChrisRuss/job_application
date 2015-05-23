#encoding: UTF-8
ActiveAdmin.register User do

    
  # As admin you can send an invitation to a user on the waiting list
  member_action :invite_user do
    user = User.find(params[:id])
    user.invite!(current_user)
    flash[:notice] = "#{user.email} was invited!"
    redirect_to :action => :index
  end
  
  # method used to manually activate
  member_action :force_activate do
    user = User.find(params[:id])
    
    # admin_force_activate see user model, sets all necessary flags and sends a temporary password
    user.admin_force_activate!
    
    if user.errors.empty?
      flash[:notice] = "#{user.email} was confirmed!"
    else
      flash[:error] = "Error: #{user.errors}!"
    end
    redirect_to :action => :index
  end
  
  # Possibility to set a temporary password
  member_action :change_password, :method => :put do
    user = User.find(params[:id])
    user.reset_password!(params[:user][:pw], params[:user][:pw])
    if user.errors.empty?
      flash[:notice] = "Neues Passwort gespeichert!"
    else
      flash[:error] = "Fehler: #{user.errors.messages}!"
    end
    redirect_to :action => :index
  end
  
  # Show relevant user data and also includes actions to invite and activate the user
  index do                         
    column :email                          
    column :last_sign_in_at           
    column :sign_in_count
    column I18n.t("active_admin.page.user.active") do |user|
      (user.active_for_authentication?) ? I18n.t("active_admin.page.user.active") : I18n.t("active_admin.page.user.inactive")
    end
    column(I18n.t("active_admin.page.user.invitation_sent_at")) { |user| loc(user.invitation_sent_at)}
    column(I18n.t("active_admin.page.user.invitation_accepted_at")) { |user| loc(user.invitation_accepted_at) }
    column(I18n.t("active_admin.page.user.confirmed_at")) { |user| loc(user.confirmed_at)}
    actions defaults: true do |user|
      # show link if user hasn't already accepted an invitation
      link_to(I18n.t("active_admin.page.user.invite_button"), invite_user_admin_user_path(user)) if !(user.invitation_accepted?)
    end
    actions defaults: false do |user|
      # Show link if user is ready to be activated and nothing else is "wrong"
      link_to(I18n.t("active_admin.page.user.activate_button"), force_activate_admin_user_path(user)) if !(user.active_for_authentication?)
    end
  end                                 

  filter :email                       

  form do |f|                         
    f.inputs "Admin Details" do                    
      f.input :email
    end                               
    f.actions
                    
  end
  
  form :partial => "form"
end                                   

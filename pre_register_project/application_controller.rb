class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_locale
 
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
  
  def self.default_url_options(options={})
      options.merge({ :locale => I18n.locale })
  end
  
  
  # Override authenticate_admin_user! und current_admin_user
  # um ActiveAdmin mit bestehendem Model (user) zu verwenden
  # ist nicht notwendig, sondern die methoden von cancan werden benutzt und
  # in active_admin-initializer konfiguriert. (authenticate_user, current_user)
  # Resourcen im Admin-Backend müssen eben mittels ActiveAdmin.register MODEL do  
  # controller.authorize_resource geschützt werden
  
  rescue_from CanCan::AccessDenied do |exception|
    rescError(exception)
  end
  
  def rescError(exception)
    redirect_to root_path, :alert => exception.message
  end
  
  protected
  
  def authenticate_inviter!
      raise CanCan::AccessDenied
  end
  
  private
  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end
  

end

class UserMailer < ActionMailer::Base
  default from: "oursecretproject@XXX"
  helper ActionView::Helpers::UrlHelper
  
  ## Reply to invitation request
  def invitation_request_reply(user)
    @given_hostname = ActionMailer::Base.default_url_options[:host]
    mail(:to => user.email, :subject => I18n.t("invitation_request_mail.subject"))
    headers['X-MC-GoogleAnalytics'] = "XXX"
    headers['X-MC-Tags'] = "invitreqrep"
  end
  
  ## Say hi to new invited user
  def welcome(user)
    @given_hostname = ActionMailer::Base.default_url_options[:host]
    mail(:to => user.email, :subject => I18n.t("welcome_mail.subject", :host_name => ActionMailer::Base.default_url_options[:host]))
    headers['X-MC-GoogleAnalytics'] = "XXX"
    headers['X-MC-Tags'] = "welcomenewbie"
  end
  
  # method to send a temporary password
  # Not ideal but only for special cases when admin activates an account
  def welcome_with_pass(user, tmpPass)
    @user=user
    @tmpPass=tmpPass
    @given_hostname = ActionMailer::Base.default_url_options[:host]
    mail(:to => user.email, :subject => I18n.t("welcome_mail.subject", :host_name => ActionMailer::Base.default_url_options[:host]))
    headers['X-MC-GoogleAnalytics'] = "XXX"
    headers['X-MC-Tags'] = "welcomenewbiebyadmin"
  end
  
  def already_waiting(user)
    @given_hostname = ActionMailer::Base.default_url_options[:host]
    mail(:to => user.email, :subject => I18n.t("secondrequest.subject", :host_name => ActionMailer::Base.default_url_options[:host]))
    headers['X-MC-GoogleAnalytics'] = "XXX"
    headers['X-MC-Tags'] = "secondrequest"
  end
  
  ## this method could also be included into devise mailer. Just a perspective thing.
  def already_active_user(user)
    @given_hostname = ActionMailer::Base.default_url_options[:host]
    mail(:to => user.email, :subject => I18n.t("alreadyuser.subject", :host_name => ActionMailer::Base.default_url_options[:host]))
    headers['X-MC-GoogleAnalytics'] = "XXX"
    headers['X-MC-Tags'] = "alreadyrequested"
  end
  
end

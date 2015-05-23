class BetaDevise::Mailer < Devise::Mailer
  include DeviseInvitable::Mailer
  default from: "oursecretproject@XXX"
  helper ActionView::Helpers::UrlHelper
  
  # Deliver an invitation email
  def invitation_instructions(record, opts={})
    headers['X-MC-GoogleAnalytics'] = "XXX"
    headers['X-MC-Tags'] = "invited"
    super(record, opts)
  end
  
  # Different inviter, different mail...
  def reinvite_mail(record, opts={})
    headers['X-MC-GoogleAnalytics'] = "XXX"
    headers['X-MC-Tags'] = "reinvited"
    devise_mail(record, :reinvite_mail)
  end
  
  # resend invitation, probably user lost his first mail...
  def resend_invite(record, opts={})
    headers['X-MC-GoogleAnalytics'] = "XXX"
    headers['X-MC-Tags'] = "resendinvite"
    initialize_from_record(record)
    mail headers_for(:invitation_instructions, opts).merge({subject: I18n.t("devise.mailer.resend_invite.subject")})
  end
  
end

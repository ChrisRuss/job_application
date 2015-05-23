#encoding: utf-8
module Refinery
  module Contacts
    class Setting < Refinery::Core::BaseModel

      ## Class for pre-setting configs

      class << self
        def confirmation_body
          Refinery::Setting.find_or_set(:contact_confirmation_body,
            "Thank you for your contact %name%,\n\nThis email is a receipt to confirm we have received your contact and we'll be in touch shortly.\n\nThanks."
          )
        end

        def confirmation_subject
          Refinery::Setting.find_or_set(:contact_confirmation_subject,
                                        "Thank you for your contact")
        end

        def confirmation_subject=(value)
          Refinery::Setting.set(:contact_confirmation_subject, value)
        end

        def notification_recipients
          Refinery::Setting.find_or_set(:contact_notification_recipients,
                                        (Role[:refinery].users.first.try(:email) if defined?(Role)).to_s)
        end

        def notification_subject
          Refinery::Setting.find_or_set(:contact_notification_subject,
                                        "New contact from your website")
        end
        
        
        #### use for the contact us box
        def default_contact_street
          Refinery::Setting.find_or_set(:street, "Sesamestreet")
        end
        
        def default_contact_city
          Refinery::Setting.find_or_set(:city, "BigTown, 12345")
        end
        
        def default_contact_fon
          Refinery::Setting.find_or_set(:fon, "+12 3456 / 789 0123")
        end
        
        def default_contact_fax
          Refinery::Setting.find_or_set(:fax, "+12 3456 / 789 0123")
        end
        
        def default_contact_mail
          Refinery::Setting.find_or_set(:contact_mail, "christianruss@me.com")
        end
        
        def default_contact_web
          Refinery::Setting.find_or_set(:web_address, "jobapply-chris.herokuapp.com")
        end
        
      end

    end
  end
end

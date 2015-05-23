module Refinery
  module Contacts
    class Contact
      
      # Uisng a non stored model to use rails forms the easier way with
      # validation features etc...
      include ActiveModel::Validations
      include ActiveModel::Conversion # for form
      extend  ActiveModel::Translation
      
      attr_accessor :subject, :email, :message

      alias_attribute :name, :subject

      # We have validated the first string field for you.
      validates :subject,:email, :presence => true
      validates_format_of :email, :with => /.+@.+\..+/i
            
      # for mass assignment
      def initialize(attributes = {})
        attributes = {} if attributes == nil
        attributes.each do |name, value|
          send("#{name}=", value)
        end
      end
      
      def persisted?
        false
      end
      
      class << self
        def i18n_scope
          :activerecord
        end
      end
      
    end
  end
end

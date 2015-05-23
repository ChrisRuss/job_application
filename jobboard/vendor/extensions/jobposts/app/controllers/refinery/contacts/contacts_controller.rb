module Refinery
  module Contacts
    class ContactsController < ::ApplicationController

      before_filter :find_page, :only => [:create, :new]
      before_filter JobpostLoader.new(), :only => [:create, :new, :thank_you]

      def index
        redirect_to :action => "new"
      end

      def thank_you
        @page = Refinery::Page.find_by_link_url("/contacts/thank_you", :include => [:parts])
      end

      def new
        @contact = Contact.new
      end

      def create
        @contact = Contact.new(params[:contacts_contact])

        if @contact.valid?
          begin
            Mailer.notification(@contact, request).deliver
          rescue => e
            logger.warn "There was an error delivering the contact notification.\n#{e.message}\n"
          end

          begin
            Mailer.confirmation(@contact, request).deliver
          rescue => e
            logger.warn "There was an error delivering the contact confirmation:\n#{e.message}\n"
          end

          redirect_to refinery.thank_you_contacts_contacts_path
        else
          render :new
        end
      end

    protected

      def find_page
        @page = Refinery::Page.find_by_link_url('/contacts/new', :include => [:parts])
      end

    end
  end
end

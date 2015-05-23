# encoding: utf-8
module Refinery
  module Jobposts
    class Jobpost < Refinery::Core::BaseModel
      self.table_name = 'refinery_jobposts'
        
      # Define allowed inputs for region, joblevel and field. Static definition as views will also be able to access via Class
      ALLOWED_REGION = ["Germany", "Europe", "Worldwide"]
      ALLOWED_JOBLEVEL = ["Expert", "Team Leader", "Management", "CEO Level"]
      ALLOWED_FIELD = ["Research", "Production", "Sales", "Logistics", "Marketing", "Controlling", "IT"]
      
      ### override to_param as we will use the token to identify jobpost ###
      def to_param
        token
      end
      
      uniquify :token

      # Setting index for search
      acts_as_indexed :fields => [:title, :working_field, :region, :job_level, :job_description, :token]
      
      # scopes are defined with separate lambda to make sure only allowed
      # terms are used. by using given as parameter, it's not really a
      # security issue, more for convenience.
      scope :with_region, lambda { |given = nil| 
        in_allowed_region(given) ? where(:region => given) : where(nil)
      }
      scope :with_joblevel, lambda { |given = nil| 
        in_allowed_joblevel(given) ? where(:job_level => given) : where(nil)
      }
      scope :with_field, lambda { |given = nil| 
        in_allowed_field(given) ? where(:working_field => given) : where(nil)
      }
      
      scope :is_published, where(:published  => true)
      
      # using virtual attributes for views
      attr_accessor :browser_title, :meta_description
      
      # only those attributes are needed directly
      attr_accessible :title, :working_field, :region, :job_level, :job_description, :position, :published

      validates :title, :presence => true
      # Also we make sure we only save valid entries for our special fields
      validates :working_field, :inclusion => ALLOWED_FIELD
      validates :region, :inclusion => ALLOWED_REGION
      validates :job_level, :inclusion => ALLOWED_JOBLEVEL
      
      ## methods for scoped lambda ##
      def self.in_allowed_region(given = nil)
        (given != nil && ALLOWED_REGION.include?(given))
      end
      
      def self.in_allowed_joblevel(given = nil)
        (given != nil && ALLOWED_JOBLEVEL.include?(given))
      end
      
      def self.in_allowed_field(given = nil)
        (given != nil && ALLOWED_FIELD.include?(given))
      end
      
      
      ### virtual fields for view access ###
      def browser_title
        # SEO title...
        trunc_title =  helper.truncate(title.to_s, :length => (70 - (26 + working_field.to_s.length)), :omission => ' ')
        "#{trunc_title} | #{working_field}"
      end
        
      def meta_description
        helper.truncate("#{::I18n.l(created_at)} - #{helper.strip_tags(job_description)}", :length => 150)
      end
      
      private
      
      class InnerHelper
        include ActionView::Helpers::TextHelper
        include ActionView::Helpers::SanitizeHelper
      end

      def helper
        @h ||= InnerHelper.new
      end
      
    end
  end
end

module Refinery
  module Colleagues
    class Colleague < Refinery::Core::BaseModel
      self.table_name = 'refinery_colleagues'
      
      # we use these methods to generate a SEO friendly title
      attr_accessor :browser_title, :meta_description
      attr_accessible :name, :pos_title, :fon, :fax, :mail, :pic_id, :description, :position

      acts_as_indexed :fields => [:name, :pos_title, :fon, :fax, :mail, :description]

      validates :name, :presence => true, :uniqueness => true
      validates :mail, :presence => true

      belongs_to :pic, :class_name => '::Refinery::Image'
      
      ### virtual fields for SEO ###
      def browser_title
        "#{name}"
      end
        
      def meta_description
        helper.truncate("#{name}, #{pos_title} - #{helper.strip_tags(description)}", :length => 150)
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

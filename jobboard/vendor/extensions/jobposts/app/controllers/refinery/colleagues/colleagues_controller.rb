#encoding: utf-8
module Refinery
  module Colleagues
    class ColleaguesController < ::ApplicationController

      before_filter :find_all_colleagues
      before_filter :find_page
      
      # Show joblistings also on team overview and detail page.
      before_filter JobpostLoader.new(), :only => [:index, :show]
      
      # business card format will also be provided, see show method
      respond_to :html, :vcf

      # we reroute the index page and show a list with the first member displayed
      def index
        @colleague = Colleague.first
        redirect_to refinery.colleagues_colleague_path(@colleague)
      end

      def show
        @colleague = Colleague.where(:id => params[:id]).first
        
        if @colleague.blank?
          error_404
          return
        end
        
        # use special meta information in presenter
        present(@colleague)
        
        
        respond_with @colleague do |format|
          format.html
          format.vcf {
            names = @colleague.name.gsub("\n", "").split(" ").reverse
            name_string = ""
            names.each_with_index do |part, i|
              name_string += part.strip
              name_string += ";" unless (i == names.length - 1)
            end
            location = Refinery::Setting.get(:city).split(" ")
            
            ### As erb renders with \n and line breaks etc., the VCF
            ### cannot be defined in a separate view file...
            ### Also blanks and spaces etc. seem not to work properly
            ### for some phones. Ugly to include here, but seperate method
            ### doesn't work.
            vcf = <<-EOH 
BEGIN:VCARD
VERSION:3.0
N:#{name_string}
FN:#{@colleague.name.strip}
ORG:#{Refinery::Core.site_name.strip}
URL:#{refinery.colleagues_colleague_url(@colleague)}
EMAIL;TYPE=INTERNET:#{@colleague.mail}
TEL;TYPE=voice,work,pref:#{@colleague.fon}
TEL;TYPE=fax,work,pref:#{@colleague.fax}
ADR;TYPE=intl,work,postal,parcel:;;#{Refinery::Setting.get(:street)};#{location[1]};;#{location[0]};Germany
LANG:de_DE
END:VCARD
EOH

            render :text => vcf, :content_type => 'text/x-vcard'
          }
        end
      end

    protected

      def find_all_colleagues
        @colleagues = Colleague.order('position ASC')
      end

      def find_page
        @page = ::Refinery::Page.where(:link_url => "/colleagues").first
      end

    end
  end
end

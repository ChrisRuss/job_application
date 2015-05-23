module Refinery
  module Jobposts
    class JobpostsController < ::ApplicationController
      helper_method :searching?, :filtering?
      respond_to :html, :pdf
      
      # we use caching and a constant scope to make sure we only use
      # published jobposts for public view and this is defined in the 
      # query... Defining a constant is ok, will only set up and pre-save 
      # the query, execution will be done later. 
      QUERYBASE ||= Jobpost.is_published

      before_filter :find_correct_jobposts
      before_filter :find_page

      def index
        # you can use meta fields from your model instead (e.g. browser_title)
        # by swapping @page for @jobpost in the line below:
        present(@page)
      end

      def show
        @jobpost = QUERYBASE.where(:token => params[:id]).first
        
        if @jobpost.blank?
             error_404
             return
        end

        # as Jobposts have special meta informations, use those inside the presenter.
        present(@jobpost)
        
        # HTML is done with view file, PDF: external lib, seperate options for German setting (DinA4 page size)
        respond_with @jobpost do  |format|
          format.html
          format.pdf {
            render :pdf => @jobpost.token,
            :layout => 'job.pdf',
            :page_height => '297mm', :page_width => '210mm',
            :dpi => "150"
          }
          
        end
      end

    protected

    # used method to lookup and pre set job posts for list.
    # as jobs can be filtered via search keyword and via predefined
    # fields (see model), there has to be some special treatment...
      def find_correct_jobposts
        unless (params[:search].blank?) && (params[:filter].blank?)
          
          # Initialize if no filter is set at all
          params[:filter] = {:region => nil, :job_level => nil, :working_field => nil} if (params[:filter] == nil || ! params[:filter].is_a?(Hash))
          
          # Empty string means reset filter
          params[:filter] = {
             :region => ((params[:filter][:region].blank?) ? nil : params[:filter][:region]),
             :job_level => ((params[:filter][:job_level].blank?) ? nil : params[:filter][:job_level]),
             :working_field => ((params[:filter][:working_field].blank?) ? nil : params[:filter][:working_field])
             }
          
          # scoped queries used with params, because used as parameters and
          # additionally checked for permission inside of model scope methods
          if params[:search].blank?
            @jobposts = QUERYBASE.with_region(params[:filter][:region]).with_joblevel(params[:filter][:job_level]).with_field(params[:filter][:working_field]).paginate(:page => params[:page], :per_page => 20, :order => (sort_column + ' ' + sort_direction))
          else
            @jobposts = QUERYBASE.with_region(params[:filter][:region]).with_joblevel(params[:filter][:job_level]).with_field(params[:filter][:working_field]).with_query(params[:search]).paginate(:page => params[:page], :per_page => 20, :order => (sort_column + ' ' + sort_direction))
          end
          
        else
          @jobposts = QUERYBASE.paginate(:page => params[:page], :per_page => 20, :order => (sort_column + ' ' + sort_direction))
        end
      end
      
      
      # use "page template" as base to show job posts
      def find_page
        @page = ::Refinery::Page.where(:link_url => "/jobposts").first
      end
      
      # used to extend search in admin backend
      def searching?
        !params[:search].blank?
      end
      
      # check if any filter is activated, useful in front-end
      def filtering?
        params[:filter] = {} if (params[:filter] == nil)
        filter_bool = params[:filter].inject(true){ |b, i| b&&i.blank?}
        ! (params[:filter] != nil ||  filter_bool)
      end

    end
  end
end

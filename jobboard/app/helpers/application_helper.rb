module ApplicationHelper
  
  # Method to make jobpost-columns sortable, for user and admin interface
  def jobpost_column_head(column, params_optional = {})
    direction = set_direction(column)
    css_icon = (sort_direction == "desc") ? "icon-chevron-down" : "icon-chevron-up"
    css = (column == sort_column) ? "active" : nil
    params_optional = params_optional.merge({:ordering=>"#{column}", :direction => direction})

    if what_controller.include? 'Admin'
      correct_path = refinery.jobposts_admin_jobposts_path(params_optional)
    else
      correct_path = refinery.jobposts_jobposts_path(params_optional)
    end
    (link_to t("activerecord.attributes.refinery/jobposts/jobpost.#{column}"), h(correct_path), {:class => css}) + ((css == "active") ? ("<i class='#{css_icon}'></i>").html_safe : "".html_safe)
  end
  
  # sort direction "toggler"
  def set_direction(column)
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
  end
  
  # Escape and secure filter input (could be manipulated inside the request)
  def add_filter_params
    params[:filter] = {} if params[:filter] == nil
    return {'filter[working_field]' => h(params[:filter][:working_field]),'filter[region]' => h(params[:filter][:region]), 'filter[job_level]' => h(params[:filter][:job_level])}
  end
  
  # search fields are provided by the user, so make sure to "secure" output and use it in link
  def add_searchfield_params
    {:search => h(params[:search])}
  end
  
  
  ### Override browser-title for better SEO
  # Original file see 'core/app/helpers/refinery/meta_helper.rb', line 6
  def own_browser_title(yield_title=nil)
    [
      (yield_title if yield_title.present?),
      @meta.browser_title.present? ? @meta.browser_title : @meta.path,
      Refinery::Core.site_name
    ].compact.join(" | ")
  end
  
  
end

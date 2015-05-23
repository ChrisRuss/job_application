# Special module to provide helper methods
# could be included into application controller, but should also be usable
# in engine... therefore extracted to seperate module
module Sorting
  def self.included(c)
         c.helper_method :sort_column, :sort_direction, :what_controller
 end
  
  private
  
  
  def sort_column
    (self.class.name.gsub("Controller", "").gsub("::Admin", "").singularize.constantize.column_names.include? params[:ordering]) ? params[:ordering] : "created_at"  
  end  

  def sort_direction  
    (%w[asc desc].include?(params[:direction])) ?  params[:direction] : "desc"  
  end 
  
  def what_controller
    self.class.name
  end
end
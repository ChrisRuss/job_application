class JobpostLoader < Struct.new(:lim_posts)
  # this Jobpost loader is called from the controller automatically when we use before_filter, so joblist gets pre-set for the joblist widget
  def before( controller )
    lim_posts = 3 if lim_posts == nil
    # and only load published job listings
      widget_jobs = Refinery::Jobposts::Jobpost.is_published.limit(lim_posts).order("created_at DESC")
      controller.instance_variable_set(:@widget_jobs, widget_jobs)
  end


  # after_filters can be defined in the same way
  def after( controller )

  end

end
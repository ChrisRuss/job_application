xml.instruct!

# Using this sitemap to improve SEO
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do

  # We want to include sub-engine pages, so if there is a new engine,
  # include here... As we have special requirements to the inclueded engine pages
  # we have to define the output for each engine's element (page)
  jobpost_engine_url = [request.protocol, request.host_with_port, "/jobposts"].join
  colleagues_engine_url = [request.protocol, request.host_with_port, "/colleagues"].join]

# Also include all live pages in any language
  @locales.each do |locale|
    ::I18n.locale = locale
    ::Refinery::Page.live.in_menu.includes(:parts).each do |page|
     # exclude sites that are external to our own domain.
     page_url = if page.url.is_a?(Hash)
       # This is how most pages work without being overridden by link_url
       page.url.merge({:only_path => false})
     elsif page.url.to_s !~ /^http/
       # handle relative link_url addresses.
       [request.protocol, request.host_with_port, page.url].join
     end

     # Add XML entry only if there is a valid page_url found above.
     xml.url do
       xml.loc refinery.url_for(page_url)
       xml.lastmod page.updated_at.to_date
     end if page_url.present? and page.show_in_menu?
    end
    
    # Get current joblist with dates of published jobposts
    jobList = Refinery::Jobposts::Jobpost.is_published.order("created_at DESC")
    
    # Jobposts:
    xml.url do
      xml.loc jobpost_engine_url
      xml.lastmod jobList.first.updated_at.to_date
    end
    jobList.each do |jobpost|
      xml.url do
        xml.loc refinery.jobposts_jobpost_url(jobpost)
        xml.lastmod jobpost.updated_at.to_date
      end
    end
    
    # Show also teammember pages if team page is not set to draft mode...
    unless ::Refinery::Page.where(:link_url => "/colleagues").first.draft
      # this query is only needed if team page is not in draft mode.
      teammembers = Refinery::Colleagues::Colleague.order(:created_at)
      xml.url do
        xml.loc colleagues_engine_url
        xml.lastmod teammembers.first.updated_at.to_date
      end
      teammembers.each do |member|
        xml.url do
          xml.loc refinery.colleagues_colleague_url(member)
          xml.lastmod member.updated_at.to_date
        end
      end
    end

  end

end

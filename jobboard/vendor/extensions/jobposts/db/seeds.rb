# Here a short excerpt from a seed file for this project...
# it mainly contains initial page setup needed for the engines.
(Refinery.i18n_enabled? ? Refinery::I18n.frontend_locales : [:en]).each do |lang|
  I18n.locale = lang

  if defined?(Refinery::User)
    Refinery::User.all.each do |user|
      if user.plugins.where(:name => 'refinerycms-jobposts').blank?
        user.plugins.create(:name => 'refinerycms-jobposts',
                            :position => (user.plugins.maximum(:position) || -1) +1)
      end
    end
  end

  url = "/jobposts"
  if defined?(Refinery::Page) && Refinery::Page.where(:link_url => url).empty?
    page = Refinery::Page.create(
      :title => 'Job posts',
      :link_url => url,
      :deletable => false,
      :menu_match => "^#{url}(\/|\/.+?|)$"
    )
    Refinery::Pages.default_parts.each_with_index do |default_page_part, index|
      page.parts.create(:title => default_page_part, :body => nil, :position => index)
    end
  end
end
(Refinery.i18n_enabled? ? Refinery::I18n.frontend_locales : [:en]).each do |lang|
  I18n.locale = lang

  if defined?(Refinery::User)
    Refinery::User.all.each do |user|
      if user.plugins.where(:name => 'refinerycms-colleagues').blank?
        user.plugins.create(:name => 'refinerycms-colleagues',
                            :position => (user.plugins.maximum(:position) || -1) +1)
      end
    end
  end

  url = "/colleagues"
  if defined?(Refinery::Page) && Refinery::Page.where(:link_url => url).empty?
    page = Refinery::Page.create(
      :title => 'Team',
      :link_url => url,
      :deletable => false,
      :menu_match => "^#{url}(\/|\/.+?|)$"
    )
    Refinery::Pages.default_parts.each_with_index do |default_page_part, index|
      page.parts.create(:title => default_page_part, :body => nil, :position => index)
    end
  end
end
(Refinery.i18n_enabled? ? Refinery::I18n.frontend_locales : [:en]).each do |lang|
  I18n.locale = lang

  if defined?(Refinery::User)
    Refinery::User.all.each do |user|
      if user.plugins.where(:name => 'contacts').blank?
        user.plugins.create(:name => "contacts",
                            :position => (user.plugins.maximum(:position) || -1) +1)
      end
    end
  end

  url = "/contacts"
  if defined?(Refinery::Page) && Refinery::Page.where(:link_url => "#{url}/new").empty?
    page = Refinery::Page.create(
      :title => "Reach out to us",
      :link_url => "#{url}/new",
      :deletable => true,
      :menu_match => "^#{url}(\/|\/.+?|)$",
      :show_in_menu => false
    )
    thank_you_page = page.children.create(
      :title => "Thanks!",
      :link_url => "/contacts/thank_you",
      :deletable => true,
      :show_in_menu => false
    )
    Refinery::Pages.default_parts.each do |default_page_part|
      page.parts.create(:title => default_page_part, :body => nil)
      thank_you_page.parts.create(:title => default_page_part, :body => nil)
    end
  end
  
  (Refinery::Contacts::Setting.methods.sort - ActiveRecord::Base.methods).each do |setting|
    Refinery::Contacts::Setting.send(setting) unless setting.to_s =~ /=$/
  end
end



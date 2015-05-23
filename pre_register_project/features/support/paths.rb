module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I visit (.+)$/ do |page_name|
  #
  #
  def path_to(page_name)
    case page_name

    when /(?:the |)home\s?page/
      ''

    when /(?:the |)sign up page/
      '/users/sign_up'

    when /(?:the |) sign in page/
      '/users/sign_in'
      
    when /(?:the |) (?:Invitations?|invitations?) page/
      new_user_invitation_path

    # Add more mappings here.

    else
      begin
        # substitude some German words...
        page_name.gsub('Seite', 'page')
        page_name.gsub('die ', 'the ')
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)

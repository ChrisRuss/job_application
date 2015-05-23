### UTILITY METHODS ###

# Note: Like the features, the some "Given, When and Then" parts are translated from German to English, and I left out several parts, and hope it still works as spec example.

def create_visitor
  @visitor = FactoryGirl.build(:user)
end


#Attention: rewritten method.
# Integrated caching was too confusing. See #delete_user
def find_user(given_mail=@visitor.email)
  @user = User.first conditions: {:email => given_mail}
end

# I'd like to use an object rather than an email
def find_wannabe user
  @user = User.first conditions: {:email => user.email}
end

def create_unconfirmed_user(given_mail=@visitor.email)
  create_visitor
  delete_user(given_mail)
  sign_up(given_mail)
  visit '/users/sign_out'
end

def create_user(given_mail=nil)
  create_visitor
  given_mail = @visitor.email if given_mail.blank?
  @visitor.assign_attributes(email: given_mail)
  delete_user(given_mail)
  sign_up(given_mail)
  # sign up sets @user
  @user.password = @visitor.password
  @user.save!
end

def invited_user(given_mail=@visitor.email)
  find_user(given_mail)
  create_visitor
  @user.invitation_accepted_at = Time.now - 1.day
  @user.save!
end

def confirm_user(given_mail=@visitor.email)
  find_user(given_mail)
  create_visitor
  @user.confirmed_at = Time.now - 1.day
  @user.save!
end

def give_rights(rights, to_user=@user)
  to_user.add_role rights.to_sym
  to_user.save!
end

#Attention: original method was
#   @user ||= User.first conditions: {:email => @visitor.email}
# that makes the find method quite confusing
# by using || the new user only gets set when @user-variable nil
# and with changing users we would always have to set him to nil first
# Better no caching here...
def delete_user(given_mail=@visitor.email)
  @user = User.first conditions: {:email => given_mail}
  @user.destroy unless @user.nil?
end

# Additional method, again more my favour of using objects with methods...
def delete_wannabe user
  @user_delete = User.first conditions: {:email => user.email}
  @user_delete.destroy unless @user_delete.nil?
end

def sign_up(given_mail=@visitor.email)
  delete_user(given_mail)
  visit '/users/sign_up'

  fill_in t("simple_form.labels.defaults.email"), :with => given_mail
  click_button t("accountmenu.pre_register")
  find_user(given_mail)
end

def sign_in(given_mail=@visitor.email, pass=@visitor.password)
  visit '/users/sign_in'
  fill_in t("simple_form.labels.defaults.email"), :with => given_mail
  fill_in t("simple_form.labels.defaults.password"), :with => pass
  click_button t("accountmenu.sign_in")
end



def invitation_request user
  visit '/users/sign_up'
  fill_in t("simple_form.labels.defaults.email"), :with => user.email
  click_button t("accountmenu.pre_register")
  find_wannabe user
end

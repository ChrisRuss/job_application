#!/bin/env ruby
# encoding: utf-8
#language: de

### some UTILITY METHODS are already included in user_steps_methods.rb ###

### GIVEN ###
Given /^I am not (?:signed|logged) in$/ do
  visit '/users/sign_out'
end

Given /^I am (?:logged|signed) out$/ do
  visit '/users/sign_out'
end

Given /^I am (?:logged|signed) in$/ do
  create_user
  # @user is now set
  confirm_user(@user.email)
  invited_user(@user.email)
  sign_in(@user.email)
end

Given /^I am logged in as valid user with the mail address "([^\"]*?)"$/ do |arg1|
  create_user arg1
  confirm_user arg1
  invited_user arg1
  sign_in arg1
end

Given /^I exist as user$/ do
  create_user
end

Given /^I do not exist as user$/ do
  create_visitor
  delete_user
end

Given /^I exist as unconfirmed user$/ do
  create_unconfirmed_user
end

Given /^I have (admin|user|VIP|premium) rights$/ do |rights|
  if rights=="VIP"
    @user.make_vip!
  else
    give_rights(rights, @user)
  end
end

# use workflow to define a logged in admin status
Given(/^I am logged in as admin$/) do
  user = FactoryGirl.build(:user)
  user.assign_attributes(:email => "christianruss@me.com")
  find_wannabe user
  step "I exist as a user"
  step "I am not logged in"
  confirm_user
  invited_user
  @user.add_role :admin
  @user.save!
  step "I sign in with valid credentials"
  step "I see a successful sign in message"
end

Given /^I am a confirmed user$/ do
  confirm_user 
end

Given /^I am an invited user$/ do
  invited_user 
end

### WHEN ###
When /^I (?:sign|log) in with valid credentials$/ do
  create_visitor
  sign_in
end

When /^I sign up with valid credentials$/ do
  create_visitor
  sign_up
end

When /^I sign up with an invalid email$/ do
  create_visitor
  @visitor = @visitor.assign_attributes(:email => "notanemail")
  sign_up
end

When /^I sign up with wrong password confirmation$/ do
  create_visitor
  @visitor = @visitor.assign_attributes(:password_confirmation => "")
  sign_up
end

When /^I sign up without a password$/ do
  create_visitor
  @visitor = @visitor.assign_attributes(:password => "")
  sign_up
end

When /^I return to home$/ do
  visit '/'
end

# Helpermethod for page visit / navigation
When /^I (?:visit|go to) (.+)$/ do |page|
  visit path_to(page)
end

When /^I (?:sign|log) in with an invalid email$/ do
  @visitor = @user.clone
  @visitor = @visitor.assign_attributes(:email => "wrong@example.com")
  sign_in
end

When /^I (?:sign|log) in with an invalid password$/ do
  @visitor = @user.clone
  @visitor = @visitor.assign_attributes(:password => "wrongpass")
  sign_in
end

When /^I (?:log|sign) in with the (?:account|mail|user) "([^\"]*?)" (?:and password|,) "([^\"]*?)"$/ do |user, pword|
  visit '/users/sign_in'
  fill_in t("simple_form.labels.defaults.email"), :with => user
  fill_in t("simple_form.labels.defaults.password"), :with => pword
  click_button t("accountmenu.sign_in")
end

When /^I edit my account$/ do
  click_link t("accountmenu.edit_account")
  fill_in t("simple_form.labels.defaults.name"), :with => "newname"
  fill_in "user_password", :with => @visitor.password
  fill_in t("simple_form.labels.defaults.password_confirmation"), :with => @visitor.password
  fill_in t("simple_form.labels.defaults.current_password"), :with => @visitor.password
  click_button t("devise_extend.registration.update")
end

When /^I (?:view|visit) the user listing$/ do
  visit '/admin/users/'
end

When /^I request an invitation with the email "([^\"]*?)"$/ do |arg1|
  step "I am signed out"
  user = FactoryGirl.build(:user)
  user.assign_attributes(:email => arg1)
  invitation_request user
end

# For some tests on invitation sending we need time windows...
When /^I request an invitation again (within|after) (\d+)(?:h|hours) with the email "([^\"]*?)"$/ do |arg1, arg2, arg3|
  arg2=arg2.to_i
  theuser = User.find_by_email(arg3)
  theuser.should_not be_nil
  case arg1
  when "after"
    theuser.updated_at = (arg2.hours + 1.minutes).ago
  when "within"
    theuser.updated_at = (arg2.hours - 1.minutes).ago
  end
  
  theuser.invitation_sent_at = theuser.updated_at if theuser.invitation_sent_at
  theuser.save!
    
  theuser2 = FactoryGirl.build(:user)
  theuser2.assign_attributes(:email => arg3)
  invitation_request theuser2
end

When /^I request an invitation with an invalid email$/ do
  user = FactoryGirl.build(:user)
  user.assign_attributes(:email => "notanemail")
  invitation_request user
end

When /^I (?:press|click) (?:a|the) button(?:\swith|) "([^\"]*?)"$/ do |arg1|
  click_button(arg1)
end

When /^I request a password reset for "([^\"]*?)"$/ do |arg1|
  visit new_user_password_path
  fill_in "user_email", :with => arg1
  find("input[type='submit']").click
end

# Alias for semantic use:
When /^I confirm "([^\"]*?)" with a password reset$/ do |arg1|
  step "I request a password reset for \"#{arg1}\""
  step "\"#{arg1}\" opens the email with subject \"How to reset your password\""
  step "I click the first link in the email"
	step "fill out the field \"user_password\" with \"test123\""
	step "fill out the field \"user_password_confirmation\" with \"test123\""
	step "I click the button \"Change Password!\""
end

When /^I fill out the field "(\S+)" with "(\S+)"$/ do |fieldname, inputtext|
  fill_in fieldname, :with => inputtext
end

When /^I click (?:the button |)"([^\"]*)" inside (?:of |)"([^\"]*)"$/ do |clickable,scope_selector|
  within(scope_selector) do      
    click_on(clickable)
  end
end

When /^I invite (?:the email|)"([^\"]*?)" by using the admin menu$/ do |arg1|
  step "I visit the user listing"
  user = User.find_by_email(arg1)
  user.should_not be_nil
  step "I click \"Invite!\" inside of \"tr#user_#{user.id}\""
end

# Autmatization of sending an Invitation as VIP User.
When /^I as a VIP user (?:with the email "([^\"]*?)" |)invite (?:the email |)"([^\"]*?)" using the invitation form$/ do |arg0, arg1|
  step "I am logged out"
  if arg0.blank? 
    step "I am logged in"
  else
    step "I am logged in as valid user with the mail address \"#{arg0}\""
  end
  step "I have VIP rights"
  step "I visit the invitation page"
  step "I should see the text \"Send invitation\""
  step "fill out the field \"user_email\" with \"#{arg1}\""
  step "I click the button with \"Invite!\""
  step "I should see the meesage \"#{t(:send_instructions, :scope => [:devise, :invitations], :email => arg1)}\""
  step "\"#{arg1}\" should be stored in the database"
end


When /^I as VIP user (?:with the email "([^\"]*?)" |)request an invitation again (within|after) (\d+)(?:h|hour(?:s|)) for the email "([^\"]*?)" using the invitation form$/ do |arg0, arg1, arg2, arg3|
  arg2=arg2.to_i
  theuser = User.find_by_email(arg3)
  theuser.should_not be_nil
  case arg1
  when "after"
    theuser.updated_at = (arg2.hours + 1.minutes).ago
  else
    theuser.updated_at = (arg2.hours - 1.minutes).ago
  end
  
  theuser.invitation_sent_at = theuser.updated_at if theuser.invitation_sent_at
  theuser.save!
  
  # now we can use the regular step, as we have set the time windows
  if arg0.blank?
    step "I as a VIP user invite \"#{arg3}\" using the invitation form"
  else
    step "I as a VIP user with the email \"#{arg0}\" invite \"#{arg3}\" using the invitation form"
  end
  
end

# Theoretically we could use a method with a parameter to define the role,
# but currently the following is enough
# Using this method makes it possible to check if referring user will be 
# set correctly. Therefore we need caching
When /^the VIP user is (?:in the |)cache?$/ do
  print "If we use the cached VIP method: Be aware, VIP role can change, please always check for correct role and usage!"
  @cached_user = @visitor
end

When /^(?:the user |)"([^\"]*?)" follows the invitation link$/ do |arg1|
  user = User.find_by_email(arg1)
  user.should_not be_nil
  user.invitation_sent_at.should_not be_nil
  user.invitation_token.should_not be_nil
  invite_link = Rails.application.routes.url_helpers.accept_user_invitation_url(:invitation_token => user.invitation_token, :host => ActionMailer::Base.default_url_options[:host], :invitermail => user.invited_by.email).gsub("&", "&amp;")
  step "I follow \"#{invite_link}\" in the mail"
  # possible debugging:
  # save_and_open_page
end

When /^I do an incomplete password reset for (?:the receipient |the email(?: address|) |the user |)"([^\"]*?)"$/ do |arg1|
  visit new_user_password_path
  fill_in "user_email", :with => arg1
  find("input[type='submit']").click
end

# Using generic steps to build a concrete method
When /^I provide a new password$/ do
	step "fill out the field \"user_password\" with \"test123\""
	step "fill out the field \"user_password_confirmation\" with \"test123\""
	step "I click the button with \"Change Password!\""
end


When /^(?:the receipient(?: with the email(?: address|)|) |)"([^\"]*?)" confirms (?:his|her) invitation$/ do |arg1|
  step "\"#{arg1}\" should receive an email with the subject \"You've got an invitation!\""
  step "\"#{arg1}\" opens the email with subject \"You've got an invitation!\""
  step "\"#{arg1}\" follows the invitation link"
  step "I should be forwarded to the accept_user_invitation page"
  step "I provide a new password"
  step "I should see the text \"Your password has been saved.\""
end

When /^I activate the (?:account |user |)(?:with the email(?: address|) |)"([^\"]*?)"$/ do |arg1|
  step "I visit the user listing"
  user = User.find_by_email(arg1)
  user.should_not be_nil
  step "I click \"Activate!\" inside \"tr#user_#{user.id}\""
end
  

### THEN ###

Then /^I should be (?:logged|signed) in$/ do
  page.should have_content t("accountmenu.logout")
  page.should_not have_content t("accountmenu.sign_up")
  page.should_not have_content t("accountmenu.sign_in")
end

Then /^I should be (?:logged|signed) out$/ do
  page.should_not have_content t("accountmenu.logout")
  page.should have_content t("accountmenu.sign_up")
  page.should have_content t("accountmenu.sign_in")
end

Then /^I should see a (?:message|notice|text) about an (?:unconfirmed account|unconfirmed user)$/ do
  page.should have_content t("devise.failure.unconfirmed")
end

Then /^I should see a (?:message|notice|text) about a successful login(?: attempt|)$/ do
  page.should have_content t("devise.sessions.signed_in")
end

Then /^I should see a (?:message|notice|text) about a successful (?:sign up|registration)$/ do
  page.should have_content t("devise.registrations.signed_up")
end

Then /^I should see a (?:message|notice|text) about an invalid email(?: address|)$/ do
  page.should have_content (t("simple_form.labels.defaults.email") + t("errors.messages.invalid"))
end

Then /^I should see a (?:message|notice|text) about a missing password$/ do
  page.should have_content (t("simple_form.labels.defaults.password") + t("errors.messages.empty"))
end

Then /^I should see a (?:message|notice|text) about a missing password confirmation$/ do
  page.should have_content t("errors.messages.confirmation")
end

Then /^I should see a (?:message|notice|text) about an invalid password confirmation$/ do
  page.should have_content t("errors.messages.confirmation")
end

Then /^I should see a (?:message|notice|text) about a successful (?:sign|log) out$/ do
  page.should have_content t("devise.sessions.signed_out")
end

Then /^I should see a (?:message|notice|text) about an invalid (?:sign|log) in(?: attempt|)$/ do
  page.should have_content t("devise.failure.invalid")
end

Then /^I should see a (?:message|notice|text) about an edited (?:account|user account)$/ do
  page.should have_content t("devise.registrations.updated")
end

Then /^(?:I should see my|the user should see his) name$/ do
  create_user
  page.should have_content @user[:name]
end

Then /^I should not be found as user$/ do
  (User.first conditions: {:email => @visitor.email}).should == nil
end

Then /^I should see a button (?:with |)"([^\"]*?)"$/ do |arg1|
  page.should have_button(arg1)
end

Then /^I should see (?:a |the |)(?:message |notice |text )(?:with |)"([^\"]*?)"$/ do |text|
  page.should have_content(text)
end

Then /^the (?:message|notice) should be (?:a|an) (success|error)?(?: message| notice)$/ do |switchcase|
  searchtext = ""
  case switchcase
  when "success"
    page.has_css?('div.alert-success')
  when "error"
    page.has_css?('div.alert-error')
  end
end

Then /^I should see a form with (?:the |a |)field "([^\"]*?)"$/ do |arg1|
  page.should have_content (arg1)
end

Then /^(?:the email(?: address|) |)"([^\"]*?)" should be (?:stored|found) in the database$/ do |arg1|
  test_user = User.find_by_email(arg1)
  test_user.should respond_to(:email)
end

Then /^(?:the account |the user )(?:with the email(?: address |)"([^\"]*?)" should be unconfirmed$/ do |arg1|
  test_user = User.find_by_email(arg1)
  test_user.confirmed_at.should be_nil
end

Then /^(?:the account |the user )(?:with the email(?: address |)"([^\"]*?)" should be confirmed$/ do |arg1|
  test_user = User.find_by_email(arg1)
  test_user.confirmed_at.should_not be_nil
end

Then /^I should see "([^\"]*?)" in a listing$/ do |tofind|
  page.should have_content(tofind)
end

Then /^(?:the account |the user )(?:with the email(?: address |)"([^\"]*?)" should be marked as inactive$/ do |arg1|
  ((find("td.email", :text => arg1)).parent).should have_content(/[Ii]nactive/)
end

Then /^(?:the account |the user )(?:with the email(?: address |)"([^\"]*?)" with (?:the |)password "([^\"]*?)" should not be able to log in$/ do |arg1, arg2|
  step 'I am logged out'
	step 'I sign in with the user "#{arg1}" and password "#{arg2}"'
  (page.should have_content(/#{"t('devise.failure.inactive')"}|#{"t('devise.failure.invalid')"}/))
end

Then /^(?:the account |the user )(?:with the email(?: address |)"([^\"]*?)" should be set (inactive|active) inside the database$/ do |arg1, arg2|
  user = User.find_by_email(arg1)
  user.should_not be_nil
  case arg2
    when "active"
      (user.active_for_authentication?).should be_true
    when "inactive"
      (user.active_for_authentication?).should_not be_true
  end
end

Then /^the email should contain a link to confirm the invitation$/ do
  user = User.find_by_email(current_email_address)
  user.should_not be_nil
  user.invitation_sent_at.should_not be_nil
  user.invitation_token.should_not be_nil
  invite_link = Rails.application.routes.url_helpers.accept_user_invitation_url(:invitation_token => user.invitation_token, :host => ActionMailer::Base.default_url_options[:host])
  invite_link.should have_content(user.invitation_token)
  step "I should see \"#{invite_link}\" in the email body"
end

Then /^(?:the email(?: address|) |user |)"([^\"]*?)" should receive (one|no|\d+) invitation mail?$/ do |arg1, arg2|
  case arg2
  when "one"
    step "\"#{arg1}\" should receive an email with the subject \"You've got an invitation!\""
    step "\"#{arg1}\" opens the email with the subject \"You've got an invitation!\""
    step "the email should contain a link to confirm the invitation"
  when "no"
    step "\"#{arg1}\" should receive no emails with subject \"You've got an invitation!\""  
  else
    step "\"#{arg1}\" should receive #{arg2.to_i} emails with subject \"You've got an invitation!\""
  end
end

Then /^the cached user should be inviter of (?:the email(?: address|) |)"([^\"]*?)"$/ do |arg1|
  # In-memory changes might not be visible, so reload user
  user = User.find_by_email(arg1)
  user.should_not be_nil
  (user.invited_by.email == @cached_user.email).should be_true
end

Then /^(?:the email(?: address|) |user |)"([^\"]*?)" should be inviter of (?:the email(?: address|) |user |)"([^\"]*?)"$/ do |arg0, arg1|
  inviter = User.find_by_email(arg0)
  user = User.find_by_email(arg1)
  user.should_not be_nil
  (user.invited_by.email == inviter.email).should be_true
end

Then /^I should see (?:the email(?: address|) of the |)cached user as (.+) parameter in the opened email$/ do |arg1|
  escapedstring = {("#{arg1}").parameterize.underscore.to_sym => @cached_user.email}.to_query
  step "I should see \"#{escapedstring}\" in the email body"
end

Then /^I should (?:have been|be) forwarded to the (.+) page$/ do |arg1|
  uri = URI.parse(current_url)
  arg1.gsub(" ", "_")
  "#{uri.path}".should == (send("#{arg1}_path"))
end
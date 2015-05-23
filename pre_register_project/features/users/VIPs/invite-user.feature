#language: en

Feature: Invite users to the platform
  As a VIP user
  I want to be able to invite users
  to allow users to access the platform
  
  Background:
		Given I am logged in
		And I have VIP rights
    
    
	Scenario: VIP user should find form on invitation page
		When I visit the invitation page
		Then I should see the text "Send an invitation"
		And I should see a form with the field "email"
		And I should see a button "Invite!"
    
    
  Scenario: unknown person gets invited by a VIP user
		When I visit the invitation page
		And I fill out the field "user_email" with "christianruss@me.com"
		And I click the button with "Invite!"
		Then I should see a message "Invitation was sent, thank you for your recommendation!"
    And "christianruss@me.com" should be stored in the database
    And "christianruss@me.com" should be unconfirmed
		# the invited user has to accept to be confirmed...
		And the user "christianruss@me.com" with the password "test123" should not be able to log in
    Then "christianruss@me.com" should receive an email with subject "You have been invited!"
    
    
  	Scenario: Even after an invite, a password reset should still not lead to an active account
  		When I request an invitation with the email "christianruss@me.com"
  		And I confirm "christianruss@me.com" with a password reset
  		And I as VIP user invite the email "christianruss@me.com" using the invitation form
      Then "christianruss@me.com" should be set inactive inside the database
      And  "christianruss@me.com" should receive an email with subject "You have been invited!"
    
    
  Scenario: Invited user receives invitation mail with activation link
		When I visit the invitation page
		And I fill out the field "user_email" with "christianruss@me.com"
		And I click the button with "Invite!"
    And  "christianruss@me.com" opens the email with subject "You have been invited!"
		Then I should see the email of the cached user as invitermail parameter in the opened email
    
		
		Scenario: Accepted user is invited again but as we are in secret mode, no message should reveal any information
			When I as VIP user with the email "numberonevip@foogoo.info" invite the email "kontakt@foogoo.info" using the invitation form
			And I am logged out
			And  "christianruss@me.com" confirms his invitation
      # Confirm autmatically signs in...
			And I am logged out
			Given a clear email queue
			And I as VIP user with the email "testvip@foogoo.info" request an invitation again after 1h for the email "kontakt@foogoo.info" using the invitation form
			Then I should see the text "Invitation was sent, thank you for your recommendation!"
			And  "christianruss@me.com" should receive no emails
			And "numberonevip@foogoo.info" should be inviter of "christianruss@me.com"
    
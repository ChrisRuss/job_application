#language: en

Feature: Invited user accepts invitation
  As an invited user
  I want to be able to activate my account
  to access the platform

  Background: the user shouold already be invited
	  Given I as VIP user invite the email "christianruss@me.com" using the invitation form
	  And I am logged out


	Scenario: Invited user sees an activation token
		And "christianruss@me.com" opens the email with subject "You have been invited!"
		Then the email should contain a link to confirm the invitation
		
    
  Scenario: Invited user follows activation token - should remain inactive until sets password
	  And "christianruss@me.com" opens the email with subject "You have been invited!"
    And "christianruss@me.com" follows the invitation link
		Then I should be forwarded to the accept_user_invitation page
		And "christianruss@me.com" should be set inactive inside the database
    

	Scenario: Invited user activates his account (sets password) and gets signed in
	  And "christianruss@me.com" opens the email with subject "You have been invited!"
    And "christianruss@me.com" follows the invitation link
		And I fill out the field "user_password" with "test123"
		And I fill out the field "user_password_confirmation" with "test123"
		And I click the button with "Change Password!"
		Then "christianruss@me.com" should receive an email with subject "Welcome"
		And I should see the text "Your password was saved"
		And "christianruss@me.com" should be set active inside the database
		And I should be signed in
    
		
	Scenario: Accepted user requests invitation again
		And  "christianruss@me.com" confirms his invitation
		# We have to log out again as confirmation automatically signs in
    And I am logged out
		And I request an invitation with the email "christianruss@me.com" again after 4h
		Then I should see the text "Thank you for your interest"
		And  "christianruss@me.com" should receive an email with subject "You are already registered and confirmed"
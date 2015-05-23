#language: en

### Actually this functionality may be too big, future: break down a bit more
Feature: Request an invitation
	As visitor
  I want to be able to request an invitation
	to get access as early as possible
	
	Background:
		Given I am not logged in
		
    
	Scenario: visitor sees the home page
    When I visit the home page
		Then I should see a button with "Request invitation"
    
    
  Scenario: visitor sees the form to request an invitation
    When I visit the homepage
    And I click the button with "Request Invitation"
    Then I should see a form with the field "email"
    
    
  Scenario: user signs up correctly to receive an invitation
    When I request an invitation with the email "christianruss@me.com"
    Then I should see a text "Thank you for your interest" sehen
    And the message should be a success message
    And the email "christianruss@me.com" should be stored in the database
    And "christianruss@me.com" should be unconfirmed
    And "christianruss@me.com" should receive an email with subject "You joined our waiting list!"
    
    
  Scenario: visitor requests invitation with an invalid email
    When I request an invitation with an invalid email
    Then I should see a text about an invalid email
		
		
	Scenario: user on the waiting list tries to activate his account with a password reset - and should not be active
		When I request an invitation with the email "christianruss@me.com"
		And I request a password reset for "christianruss@me.com"
		When "christianruss@me.com" opens the email with subject "How to reset your password"
		Then I should see "password" in the email body
		When I click the first link in the email
		Then I should see a form with the field "password"
    When I provide a new password
		Then I should see the text "Your password was saved."
		And "christianruss@me.com" should be confirmed
		When I sign in with the user "christianruss@me.com" and password "test123"
		Then I should see the text "Your account is not active."
    
    
	Scenario: To prevent spamming attempts, when a user requests an invitation again within 4 hours we don't send a new mail
		When I request an invitation with the email "christianruss@me.com"
		And I request an invitation with the email "christianruss@me.com" again within 4h
    # Super suspicious mode, don't tell anything on front-end
    Then I should see a text "Thank you for your interest"
		Then "christianruss@me.com" should receive 1 email
		And  "christianruss@me.com" should receive no email with subject "You already joined the waiting list" erhalten
		
    
	Scenario: person on the waiting list requests an invitation again after 4 hours - then it's not an accident or spamming, send again 2nd mail
		When I request an invitation with the email "christianruss@me.com"
		And I request an invitation with the email "christianruss@me.com" again after 4h
    Then I should see the text "Thank you for your interest"
		Then "christianruss@me.com" should receive 2 emails
		And  "christianruss@me.com" should receive an email with subject "You already joined the waiting list" erhalten
		
    
	Scenario: user is already invited and probably hasn't received his invitation and makes a request again
		When I as VIP user invite the email "christianruss@me.com" using the invitation form
		And I am logged out
		And I request an invitation with the email "christianruss@me.com" again after 1h
		Then I should see the text "Thank you for your interest"
		And  "christianruss@me.com" should receive 2 emails
    And  "christianruss@me.com" should receive an invitation mail
		And  "christianruss@me.com" should receive an email with subject "Thank you for your interest. You've already been invited. Here again your invitation."
    
  
  Scenario: Inviting person should also be tracked and set correctly
	  When I as VIP user invite the email "christianruss@me.com" using the invitation form
	  And I am logged out
    And the VIP user is in the cache
		Then the cached user should be the inviter of "christianruss@me.com"
			
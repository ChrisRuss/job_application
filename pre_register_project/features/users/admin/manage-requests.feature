#language: en

Feature: Manage people waiting for invitations
  As an admin
  I want to be able to manage a list of the requests
  to invite the waiting people
		
  Background:
    Given I request an invitation with the email "christianruss@me.com"
    And I am logged in as admin
    
    
	Scenario: Admin visits the user listing
    When I view the user listing
		Then I should see "christianruss@me.com" in a listing
		And "christianruss@me.com" should be unconfirmed
		And "christianruss@me.com" should be marked as inactive
    
    
  Scenario: Admin invites a waiting user that should still be inactive until he confirms
    When I view the user listing
  	And I invite "christianruss@me.com" by using the admin menu
    Then "christianruss@me.com" should be set inactive inside the database
    And "christianruss@me.com" should receive an email with subject "You have been invited!"
    
    
	Scenario: As admin we don't want to be the "inviter" of a user, so make sure old one stays when inviting
		Given a clear email queue
		# First we have to log out as admin. This scenario could be moved to a new feature, but then it get's quite confusing about the features...
    And I am logged out
		When I as VIP user invite the email "christianruss@me.com" using the invitation form
		And I am logged in as admin
		And the VIP user is in the cache
		And I invite "christianruss@me.com" by using the admin menu
		Then the cached user should be inviter of "christianruss@me.com"
			
		
		Scenario: Admin activates user completely, user gets a welcome mail
			When I view the user listing
      And I activate the user "christianruss@me.com"
			Then "christianruss@me.com" should be confirmed
			Then "christianruss@me.com" should be set active inside the database
			And  "christianruss@me.com" should receive an email with subject "Welcome"
		
    
	Scenario: Non-admins should not be able to see the requests
    # First we have to log out as admin...
		Given I am logged out
		Given I am logged in    
		And I have user rights
		When I view the user listing
		Then the message should be an error message
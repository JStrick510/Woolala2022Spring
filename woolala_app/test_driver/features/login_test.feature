Feature: Validate login screen

    Scenario: User launches the app
        Given I am on the "Login" screen
        Then I should see "Login With:" on my screen

    Scenario: Google Login
        Given My "Google" account is "valid"
        When I tap the "Google" button
        Then I should see "Homepage" on my screen

        Given My "Google" account is "not valid"
        When I tap the "Google" button
        Then I should see "Login With:" on my screen

    Scenario: Facebook Login
        Given My "Facebook" account is "valid"
        When I tap the "Facebook" button
        Then I should see "Homepage" on my screen

        Given My "Facebook" account is "not valid"
        When I tap the "Facebook" button
        Then I should see "Login With:" on my screen

    Scenario: Sign out of an account
        Given I am on the "Login" screen
        When I tap the "Google" button
        Then I should see "Homepage" on my screen
        When I tap the "Sign Out" button
        Then I should see "Login With:" on my screen
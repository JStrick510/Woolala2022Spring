Feature: Validate login screen

    Scenario: User launches the app
        Given The "app" is open
        Then I should see "Login With:" on my screen

    Scenario: Google Login
        Given My "Google" account is "valid"
        When I tap the "Google" button
        Then I should see "homepage" on my screen

        Given My "Google" account is "not valid"
        When I tap the "Google" button
        Then I should see "Login With:" on my screen

    Scenario: Facebook Login
        Given My "Facebook" account is "valid"
        When I tap the "Facebook" button
        Then I should see "homepage" on my screen

        Given My "Facebook" account is "not valid"
        When I tap the "Facebook" button
        Then I should see "Login With:" on my screen
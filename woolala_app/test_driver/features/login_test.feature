Feature: Validate login screen

    Scenario: User launches the app
        When I tap the "Google" button

    Scenario: Google Login
        When I tap the "google" icon
        Then I should see "google" log-in api

        When I pass the "google" authentication
        Then I should have "homepage" on screen

    Scenario: Facebook login
        When I tap the "facebook" icon
        Then I should see "facebook" log-in api

        When I pass the "facebook" authentication
        Then I should have "homepage" on screen
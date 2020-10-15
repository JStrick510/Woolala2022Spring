Feature: Validate login screen

    Scenario: User launches the app
        When I launch the app
        Then I should have "login" on screen

    Scenario: Google Login
        When I tap the "google" icon
        Then I should see "google" log-in api

        When I pass the "google" authentication
        Then I should have "homepage" on screen

        When I fail the "google" authentication
        Then I should see "Sign-In Failed" on screen

    Scenario: Facebook login
        When I tap the "facebook" icon
        Then I should see "facebook" log-in api

        When I pass the "facebook" authentication
        Then I should have "homepage" on screen

         When I fail the "facebook" authentication
         Then I should see "Sign-In Failed" on screen

    Scenario: Home Screen
        When I login with an account
        Then I should see the Homepage Screen
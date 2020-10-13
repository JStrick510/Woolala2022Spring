Feature: Validate login screen

    Scenario: Users start to login
        When I tap the "google" icon
        Then I should see "google" log-in api

        When I tap the "facebook" icon
        Then I should see "facebook" log-in api

    Scenario: Users successfully login
        When I pass the "google" authentication
        Then I should have "homepage" on screen

        When I pass the "facebook" authentication
        Then I should have "homepage" on screen
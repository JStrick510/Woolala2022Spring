Feature: Validate image searching

    Scenario: User searches profile
        Given I am on the "Homepage" screen
        When I tap the "Search" button
        Then I should see "Search Page" on my screen

    Scenario: Search Body suggests candidate words
        Given I am on the "Search Page" screen
        When I edit "Search Bar"
        Then I should see recommendations or previous search records

    Scenario: User goes back to homepage
        Given I am on the "Profile" screen
        When I tap the "back arrow" button
        Then I should see "Homepage" screen
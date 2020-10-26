Feature: Validate image searching

    Scenario: User searches profile
        Given I am on the "Homepage" screen
        When I tap the "Search" button
        Then I should see "Search Page" on my screen

    Scenario: Search Body suggests candidate words
        Given I am on the "Search Page" screen
        When "Search Bar" is edited
        Then I should see "Recommendations" on my screen

    Scenario: User goes back to homepage
        Given I am on the "Profile" screen
        When I tap the "back arrow" button
        Then I should see "Homepage" on my screen
Feature: Validate Profile

    Scenario: User checks profile
        Given I am on the "Homepage" screen
        When I tap the "To Profile" button
        Then I should see "Profile" on my screen

    Scenario: User edits profile
        Given I am on the "Profile" screen
        When I tap the "Edit Profile" button
        Then I should see "Edit Profile" on my screen

    Scenario: User updates profile
        Given I am on the "Edit Profile" screen
        When "Profile Name" is edited
        Then I should see "Update" button able to be clicked

        Given I am on the "Edit Profile" screen
        When "Bio" is edited
        Then I should see "Update" button able to be clicked

    Scenario: User checks updated profile
        Given I am on the "Edit Profile" screen
        When I tap the "check mark" button
        Then I should see "Profile" on my screen
        And "Profile Name" and "Bio" is updated

    Scenario: User goes back to homepage
        Given I am on the "Profile" screen
        When I tap the "back arrow" button
        Then I should see "Homepage" screen
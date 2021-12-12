Feature: Validate Profile

    Scenario: User updates profile
        Given I am already logged in
        When I tap the "Profile" button
        Then I should see "Profile" on my screen
        Given I am on the "Profile" screen
        When I tap the "Edit Profile" button
        Then I should see "Edit Profile" on my screen
        Given I am on the "Edit Profile" screen
        When "Profile Name" is edited
        Then I should see the "Update" button
        When I tap the "Check Mark" button
        Then I should see "Profile" on my screen
        And "Profile Name" is updated

        Given I am on the "Profile" screen
        When I tap the "Edit Profile" button
        Then I should see "Edit Profile" on my screen
        Given I am on the "Edit Profile" screen
        When "Bio" is edited
        Then I should see the "Update" button
        When I tap the "Check Mark" button
        Then I should see "Profile" on my screen
        And "Bio" is updated
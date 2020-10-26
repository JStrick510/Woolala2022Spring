Feature: Validate image postings

    Scenario: User checks profile
        Given I am on the "Homepage" screen
        When I tap the "Make post" button
        Then I should see "Select Images" on my screen

    Scenario: User uploads images from Library
        Given I am on the "Select Images" screen
        When I tap the "Library" button
        Then I should see "My libraries" screen
        When I choose an image from "My libraries"
        Then I should see "upload" button
        When I tap the "upload" button
        Then I should see the "Select Images" screen
        And the "Selected Images" are on the "Select Images" screen

    Scenario: User uploads images by camera
        Given I am on the "Select Images" screen
        When I tap the "Camera" button
        Then I should see my camera
        When I tap the "Shutter" button
        Then I should see "upload" button
        When I tap the "upload" button
        Then I should see the "Select Images" screen
        And the "Selected Images" are on the "Select Images" screen
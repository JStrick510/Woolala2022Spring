Feature: Validate image postings

    Scenario: User posts images from their gallery
        Given I am already logged in
        When I tap the "Make Post" button
        Then I should see "Camera" and "Gallery" on my screen
        When I tap the "Gallery" button
        Then I should be able to choose an image to upload

    Scenario: User uploads images by camera
        Given I am already logged in
        When I tap the "Make Post" button
        Then I should see "Camera" and "Gallery" on my screen
        When I tap the "Camera" button
        Then I should be able to choose an image to upload

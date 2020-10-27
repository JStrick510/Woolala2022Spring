Feature: Validate image searching

    Scenario: User searches profile
        Given I am already logged in
        When I tap the "Search" button
        When I tap the "Search Icon" button
        Then I should see "ListView" on my screen
Feature: Fetch queries

  Scenario: Fetch query and print its xml
    When I expect query "QUERY"
    And I run "wolf -x QUERY"
    Then I should see XML

  Scenario: Fetch query
    When I expect query "QUERY"
    And I run "wolf QUERY"
    Then I should see table with results

  Scenario: Fetch query with verbose option
    When I expect query "QUERY"
    And I run "wolf QUERY"
    Then I should see table with results
    And I should see "URI: URI"
    And I should see "Found NUM pods"

  Scenario: Fetch query with all option
    When I expect query "QUERY"
    And I run "wolf QUERY -a"
    Then I should see table with all results

  Scenario: Fetch query with title option
    When I expect query "QUERY"
    And I run "wolf QUERY -t=BLAH"
    Then I should see table with certain results

  Scenario: Fetch query with menu option
    When I expect query "QUERY"
    And I run "wolf QUERY -t=BLAH"
    Then I should see table with certain results
    And I should see menu
    When I choose "1"
    Then I should see this menu item


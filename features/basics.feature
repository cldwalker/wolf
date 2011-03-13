Feature: Basic options

  Scenario Outline: Print help
  When I run "<command>"
  Then the output should contain "Usage: wolf [OPTIONS] [ARGS]"

  Examples:
    | command     |
    | wolf        |
    | wolf -h     |
    | wolf --help |

  Scenario Outline: Print version
    When I run "<command>"
    Then the output contains the current version

    Examples:
      | command        |
      | wolf -V        |
      | wolf --version |

  Scenario: Load option loads file
    Given an xml file "boston.xml"
    When I run "wolf -l boston.xml"
    Then the stdout should contain "Economic properties"
    And the output should match /^[+-]+$/

  Scenario: Local option with invalid file prints error
    When I run "wolf -l blah"
    Then the stderr should contain "Wolf Error: File 'blah' does not exist"

  Scenario: Open url with open option
    Given Pending
    When I expect open with "http://www.wolframalpha.com/input/?i=QUERY"
    Then I run "wolf QUERY -o"

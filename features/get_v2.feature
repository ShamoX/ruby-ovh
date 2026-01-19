Feature: Get v2
  We must be able to switch version and request on the right API version
  Scenario: Get request
    Given I created an OVH client with my credentials and switched to v2
    When I get '/iam/permissionsGroup' with the sdk
    Then I should have called the v2 base url

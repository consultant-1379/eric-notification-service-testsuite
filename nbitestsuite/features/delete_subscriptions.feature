Feature: Subscription deletion

  @delete-subscription-test
  Scenario: Subscription deletion OK
    Given get subscriptions is done

    Then all subscriptions found are deleted

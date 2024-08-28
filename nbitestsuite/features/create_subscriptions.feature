Feature: Subscription creation

  @create-subscription-test-NoFilter
  Scenario: Subscription NoFilter OK
    Given number of eventType <net> and number of subscriptions for eventType <nsub> with No Filter and No Projection

    Then we expect <total> subscriptions NoFilter created with response 201 or 409
    
    Examples:
        | net | nsub | total |
        |  3  |  5   |  15   |
        
  @create-subscription-test-Filter
  Scenario: Subscription Filter OK
    Given number of eventType <net> and number of subscriptions for eventType <nsub> with Filter

    Then we expect <total> subscriptions Filter created with response 201 or 409
    
    Examples:
        | net | nsub | total |
        |  3  |  5   |  15   |

  @create-subscription-test-Projection
  Scenario: Subscription Projection OK
    Given number of eventType <net> and number of subscriptions for eventType <nsub> with Projection

    Then we expect <total> subscriptions Projection created with response 201 or 409
    
    Examples:
        | net | nsub | total |
        |  3  |  5   |  15   |

  @create-subscription-test-Filter&Projection
  Scenario: Subscription Filter&Projection OK
    Given number of eventType <net> and number of subscriptions for eventType <nsub> with Filter and Projection

    Then we expect <total> subscriptions Filter&Projection created with response 201 or 409
    
    Examples:
        | net | nsub | total |
        |  3  |  5   |  15   |
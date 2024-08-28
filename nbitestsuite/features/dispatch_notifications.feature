Feature: Dispatch notifications

  @dispatch-notifications-test-NoFilter
  Scenario: Dispatch NoFilter OK
    Given Test Client is healthy
    And Test Client is reset
    And events in Kafka are created according to number of eventType <net> , number of event per eventType <ne> , number of subscriptions for eventType <nsub> with No Filter and No Projection and <t> Kafka Topic

    Then we expect <total> Notifications with No Filter and No Projection are dispatched to clients subscribed
    
    Examples:
        | net |  ne  | nsub  | t     | total |
        |  3  |  5   |  5    | event |  75   |

  @dispatch-notifications-test-Filter
  Scenario: Dispatch Filter OK
    Given Test Client is healthy
    And Test Client is reset
    And events in Kafka are created according to number of eventType <net> , number of event per eventType <ne> , number of subscriptions for eventType <nsub> with Filter and <t> Kafka Topic

    Then we expect <total> Notifications with Filter are dispatched to clients subscribed
    
    Examples:
        | net |  ne  | nsub  | t     | total |
        |  3  |  5   |  5    | event |  15   |

  @dispatch-notifications-test-Projection
  Scenario: Dispatch Projection OK
    Given Test Client is healthy
    And Test Client is reset
    And events in Kafka are created according to number of eventType <net> , number of event per eventType <ne> , number of subscriptions for eventType <nsub> with Projection and <t> Kafka Topic

    Then we expect <total> Notifications with Projection are dispatched to clients subscribed
    
    Examples:
        | net |  ne  | nsub  | t     | total |
        |  3  |  5   |  5    | event |  75   |

  @dispatch-notifications-test-FilterProjection
  Scenario: Dispatch FilterProjection OK
    Given Test Client is healthy
    And Test Client is reset
    And events in Kafka are created according to number of eventType <net> , number of event per eventType <ne> , number of subscriptions for eventType <nsub> with Filter and Projection and <t> Kafka Topic

    Then we expect <total> Notifications with Filter and Projection are dispatched to clients subscribed
    
    Examples:
        | net |  ne  | nsub  | t     | total |
        |  3  |  5   |  5    | event |  15   |
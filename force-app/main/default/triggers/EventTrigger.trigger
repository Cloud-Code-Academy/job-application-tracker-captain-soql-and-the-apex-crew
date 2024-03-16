trigger EventTrigger on Event (before insert, before update) {
    EventTriggerHandler.preventOverlappingFutureEventsForAssignedUser(Trigger.new);
}
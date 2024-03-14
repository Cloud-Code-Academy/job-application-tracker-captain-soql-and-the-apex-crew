trigger EventTrigger on Event (before insert, before update) {
    EventTriggerHandler.preventOverlappingEventsForAssignedUser(Trigger.new);
}
trigger EventTrigger on Event (before insert, before update) {
    EventTriggerHandler.preventOverlappingEvents(Trigger.new);
}
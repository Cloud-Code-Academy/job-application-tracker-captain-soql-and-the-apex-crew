trigger JobApplicationTrigger on JobApplication__c (after insert, after update) {
    switch on trigger.operationType {
        when AFTER_INSERT{
            JobApplicationTriggerHandler.createTaskBasedOnStatus(trigger.new);
            // JobApplicationTriggerHandler.setPrimaryContact(Trigger.newMap);
        }
        when AFTER_UPDATE{
            JobApplicationTriggerHandler.createTaskBasedOnStatus(trigger.new);
            // JobApplicationTriggerHandler.setPrimaryContact(Trigger.newMap);
        }
    }
}
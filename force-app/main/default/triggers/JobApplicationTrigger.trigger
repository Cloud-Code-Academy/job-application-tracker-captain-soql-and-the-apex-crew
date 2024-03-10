trigger JobApplicationTrigger on JobApplication__c (after insert, after update) {
    switch on trigger.operationType {
        when BEFORE_INSERT {
            JobApplicationHelper.setPrimaryContact(Trigger.newMap);
        }
        when AFTER_INSERT{
            JobApplicationTriggerHandler.createTaskBasedOnStatus(trigger.new);
        }
        when BEFORE_UPDATE {
            JobApplicationHelper.setPrimaryContact(Trigger.newMap);
        }
        when AFTER_UPDATE{
            JobApplicationTriggerHandler.createTaskBasedOnStatus(trigger.new);
        }
    }
}
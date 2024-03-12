trigger JobApplicationTrigger on JobApplication__c (before insert, after insert, after update) {
    switch on trigger.operationType {
        when BEFORE_INSERT{
            JobApplicationTriggerHandler.updatePrimaryContactOnInsert(trigger.new);
        }
        when AFTER_INSERT{
            JobApplicationTriggerHandler.createTaskBasedOnStatus(trigger.new);
        }
        when AFTER_UPDATE{
            JobApplicationTriggerHandler.createTaskBasedOnStatus(trigger.new);
        }
    }
}
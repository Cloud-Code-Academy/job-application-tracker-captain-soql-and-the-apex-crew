trigger JobApplicationTrigger on JobApplication__c (before insert, after insert, before, after update) {
    switch on trigger.operationType {
        when BEFORE_INSERT{
            JobApplicationTriggerHandler.assignPrimaryContactOnInsert(trigger.new);
        }
        when AFTER_INSERT{
            JobApplicationTriggerHandler.createTaskBasedOnStatus(trigger.new);
        }
        when BEFORE_UPDATE{
            JobApplicationTriggerHandler.assignPrimaryContactOnUpdate(trigger.new);
        }
        when AFTER_UPDATE{
            JobApplicationTriggerHandler.createTaskBasedOnStatus(trigger.new);
        }
    }
}
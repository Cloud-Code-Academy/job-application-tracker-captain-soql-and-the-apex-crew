/**
 * @description       : 
 * @author            : @Oizon, @off-nadir-insight @Fritzb100
 * @group             : Cohort2
 * @last modified on  : 03-16-2024
 * @last modified by  : @Fritz
**/
trigger JobApplicationTrigger on JobApplication__c (before insert, after insert, before update, after update) {
    switch on trigger.operationType {
        when BEFORE_INSERT{
            JobApplicationTriggerHandler.assignPrimaryContactOnInsert(trigger.new);
            JobApplicationTriggerHandler.estimateTakeHomePay(trigger.new);  
        }
        when AFTER_INSERT{
            JobApplicationTriggerHandler.createTaskBasedOnStatus(trigger.new);
        }
        when BEFORE_UPDATE{
            JobApplicationTriggerHandler.assignPrimaryContactOnUpdate(trigger.new);
            JobApplicationTriggerHandler.estimateTakeHomePay(trigger.new);
        }
        when AFTER_UPDATE{
            JobApplicationTriggerHandler.createTaskBasedOnStatus(trigger.new);
        }
    }
}
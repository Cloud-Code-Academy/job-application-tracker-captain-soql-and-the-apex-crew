trigger JobSearchTrigger on JobSearchCriteria__c (after insert, before insert, after update, before update, before delete, after undelete) {
    switch on trigger.operationType {
        when AFTER_INSERT, AFTER_UNDELETE{
            JobSearchTriggerHandler.scheduleNewJobSearch(Trigger.new);
        }
        when AFTER_UPDATE{
            JobSearchTriggerHandler.updateJobSearch(Trigger.new, Trigger.oldMap);
        }
        when BEFORE_DELETE{
            JobSearchTriggerHandler.clearJobSearch(Trigger.old);
        }
        when BEFORE_INSERT, BEFORE_UPDATE{
            JobSearchTriggerHandler.preventDuplication(Trigger.new);
        }
    }
}
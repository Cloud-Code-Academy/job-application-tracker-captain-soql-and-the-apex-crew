trigger JobApplicationTrigger on JobApplication__c (before insert, before update) {
    switch on Trigger.operationType {
        when BEFORE_INSERT, BEFORE_UPDATE {
            JobApplicationHelper.setPrimaryContact(Trigger.newMap);
        }
    }
}
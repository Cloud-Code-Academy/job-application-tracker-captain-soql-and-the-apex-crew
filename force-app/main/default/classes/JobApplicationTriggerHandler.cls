public with sharing class JobApplicationTriggerHandler {
    public static void setPrimaryContact(Map<Id,JobApplication__c> newJobApplicationMap) {
        for (JobApplication__c jobApp : newJobApplicationMap.values()) {
            if (jobApp.Contact__c != null){
                continue;
            } else if (areRelatedContactsAvailable(jobApp)) {
                jobApp.Contact__c = jobApp.JobApplications__r[0].Contact__c;
            } else if (isCompanyAvailable(jobApp) && areCompanyContactsAvailable(jobApp)) {
                jobApp.Contact__c = getCompanyFirstContact(jobApp);
            }
        }
    }

    private static Boolean areRelatedContactsAvailable(JobApplication__c jobApp) {
        return jobApp.JobApplications__r != null && jobApp.JobApplications__r.size()>0;
    }

    private static Boolean isCompanyAvailable(JobApplication__c jobApp) {
        return jobApp.Account__c != null;
    }
    private static Boolean areCompanyContactsAvailable(JobApplication__c jobApp) {
        List<Contact> companyContacts = [SELECT Id, LastName, AccountId FROM Contact WHERE AccountId = :jobApp.Account__c WITH SYSTEM_MODE];
        return companyContacts.size() > 0;
    }
    private static Id getCompanyFirstContact(JobApplication__c jobApp) {
        List<Contact> companyContacts = [SELECT Id, LastName, AccountId FROM Contact WHERE AccountId = :jobApp.Account__c WITH SYSTEM_MODE];
        return companyContacts[0].Id;
    }
}
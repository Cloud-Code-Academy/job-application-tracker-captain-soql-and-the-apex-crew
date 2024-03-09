public with sharing class JobApplicationHelper {
    public static void setPrimaryContact(Map<Id,JobApplication__c> newJobApplicationMap) {
        for (JobApplication__c jobApp : newJobApplicationMap.values()) {
            // if contact is added, see if there is a matching primary contact
            if (jobApp.Contact__c != null){
                continue;
            } else if (areRelatedContactsAvailable(jobApp)) {
                jobApp.Contact__c = jobApp.JobApplications__r[0].Contact__c;
            } else if (areCompanyContactsAvailable(jobApp)) {
                jobApp.Contact__c = getFirstCompanyContact(jobApp);
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
        List<Contact> companyContacts = [SELECT Id, LastName, AccountId FROM Contact WHERE AccountId = :jobApp.Account__c];
        return companyContacts.size() > 0;
    }
    private static Id getFirstCompanyContact(JobApplication__c jobApp) {
        List<Contact> companyContacts = [SELECT Id, LastName, AccountId FROM Contact WHERE AccountId = :jobApp.Account__c];
        return companyContacts[0].Id;
    }
}
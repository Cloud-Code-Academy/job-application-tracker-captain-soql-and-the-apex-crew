public with sharing class JobApplicationHelper {
    public static void setPrimaryContact(Map<Id,JobApplication__c> newJobApplicationMap) {
        for (JobApplication__c jobApp : newJobApplicationMap.values()){
            // if contact is added, see if there is a matching primary contact
            if (jobApp.Contact__c != null){
                continue;
            } else if (jobApp.JobApplications__r != null && jobApp.JobApplications__r.size()>0){
                jobApp.Contact__c = jobApp.JobApplications__r[0].Contact__c;
            }
        }
    }
}
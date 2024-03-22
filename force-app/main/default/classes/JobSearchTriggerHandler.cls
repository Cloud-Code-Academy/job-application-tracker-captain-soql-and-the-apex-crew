public with sharing class JobSearchTriggerHandler {
    public static void scheduleNewJobSearch(List<JobSearchCriteria__c> triggerDotNew) {
        //Search for crontrigger where CronJobDetail.Name = JobTitle + Location if one exist do nothing if one doesnt create it.
        Map<String, JobSearchCriteria__c> cronTitleToTriggerMap = new Map<String,JobSearchCriteria__c>();
        for(JobSearchCriteria__c search: triggerDotNew){
            if(search.IsActive__c){
                cronTitleToTriggerMap.put(searchTitle(search.JobTitle__c, search.City__c, search.StatePick__c), search);
            }
        }
        Map<String, CronTrigger> existingCronTriggerMap = new Map<String, CronTrigger>();
        for(CronTrigger crTrig : [SELECT Id,CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name IN:cronTitleToTriggerMap.keySet()]){
            existingCronTriggerMap.put(crTrig.CronJobDetail.Name, crTrig);
        }
        for(JobSearchCriteria__c search: triggerDotNew){
            String searchLabel = searchTitle(search.JobTitle__c, search.City__c, search.StatePick__c);
            if(existingCronTriggerMap.get(searchLabel) == null && search.IsActive__c){
                JoobleIntegration_Schedule scheduleJob = new JoobleIntegration_Schedule(search.JobTitle__c, search.City__c + ', ' + search.StatePick__c);
                String cron = '0 0 0 ? * *';//Every day at midnight
                System.schedule(searchLabel, cron, scheduleJob);
            }
        }

    }
    public static void updateJobSearch(List<JobSearchCriteria__c> triggerDotNew, Map<Id, JobSearchCriteria__c> triggerDotOldMap) {
        Map<String, JobSearchCriteria__c> cronTitleToTriggerMap = new Map<String,JobSearchCriteria__c>();
        Set<String> labelsToAbort = new Set<String>();
        for(JobSearchCriteria__c search: triggerDotNew){
            JobSearchCriteria__c oldSearch = triggerDotOldMap.get(search.Id);
            if((search.LabelTrig__c != oldSearch.LabelTrig__c) || (search.IsActive__c == false && oldSearch.IsActive__c)){
                labelsToAbort.add(oldSearch.LabelTrig__c);
            }
        }
        for(CronTrigger crTrig : [SELECT Id,CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name IN:labelsToAbort]){
            System.abortJob(crTrig.Id);
        }
        scheduleNewJobSearch(triggerDotNew);
    }
    public static void clearJobSearch(List<JobSearchCriteria__c> triggerDotOld){
        Set<String> searchesToDelete = new Set<String>();
        for(JobSearchCriteria__c search: triggerDotOld){
            searchesToDelete.add(searchTitle(search.JobTitle__c, search.City__c, search.StatePick__c));
        }
        for(CronTrigger crTrig : [SELECT Id,CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name IN:searchesToDelete]){
            System.abortJob(crTrig.Id);
        }
    }
    public static void preventDuplication(List<JobSearchCriteria__c> triggerDotNew){
        for(JobSearchCriteria__c search: triggerDotNew){
            search.LabelTrig__c = searchTitle(search.JobTitle__c, search.City__c, search.StatePick__c);
        }

    }
    private static String searchTitle(String title, String city, String state){
        return title + ' ' + city + ', ' + state;
    }
}
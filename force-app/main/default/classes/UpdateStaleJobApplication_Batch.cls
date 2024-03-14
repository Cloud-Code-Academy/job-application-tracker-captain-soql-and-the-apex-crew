public with sharing class UpdateStaleJobApplication_Batch implements Database.Batchable<JobApplication__c>{
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Status__c FROM JobApplication__c WHERE //TODO Stale Criteria';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<JobApplication__c> scope) {
        //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_batch.htm
        //https://salesforce.stackexchange.com/questions/80277/sample-code-to-schedule-an-apex-class
        for(JobApplication__c jobApp : scope){
            jobApp.Status__c = 'Closed';
        }
        update as system scope;
    }

    public void finish(Database.BatchableContext BC){
        System.debug('Executing secret function...');
        System.debug('Muahahahahahahahahaha!!');
    }
}
@isTest
public with sharing class JobSearchTriggerHandler_Test {
    @isTest
    static void confirmDefaultSearchCreated() {
        CronTrigger defaultJob = [SELECT CronJobDetail.Name, NextFireTime, Id FROM CronTrigger WHERE CronJobDetail.Name = 'Digital Overlord Accident, Maryland' LIMIT 1];
        Assert.areEqual('Digital Overlord Accident, Maryland', defaultJob.CronJobDetail.Name);
    }
    @isTest
    static void setDefaultSearchToInactive(){
        Test.startTest();
        JobSearchCriteria__c defaultSearch = [SELECT Id, IsActive__c FROM JobSearchCriteria__c WHERE JobTitle__c = 'Digital Overlord'];
        defaultSearch.IsActive__c = false;
        update defaultSearch;
        Test.stopTest();
        List<CronTrigger> cronList = [SELECT CronJobDetail.Name, NextFireTime, Id FROM CronTrigger WHERE CronJobDetail.Name = 'Digital Overlord Accident, Maryland'];
        Assert.areEqual(0, cronList.size());
    }
    @isTest
    static void deleteDefaultSearch(){
        Test.startTest();
        JobSearchCriteria__c defaultSearch = [SELECT Id, IsActive__c FROM JobSearchCriteria__c WHERE JobTitle__c = 'Digital Overlord'];
        defaultSearch.IsActive__c = false;
        delete defaultSearch;
        Test.stopTest();
        List<CronTrigger> cronList = [SELECT CronJobDetail.Name, NextFireTime, Id FROM CronTrigger WHERE CronJobDetail.Name = 'Digital Overlord Accident, Maryland'];
        Assert.areEqual(0, cronList.size());
    }
    @isTest
    static void testForcedLimit(){
        List<JobSearchCriteria__c> jobSearchList = new List<JobSearchCriteria__c>();
        for(Integer i = 0 ; i < 51; i++ ){
            JobSearchCriteria__c bulkSearchInsert = new JobSearchCriteria__c(
            IsActive__c = true,
            StatePick__c = 'Texas',
            City__c = 'Ding Dong',
            JobTitle__c = 'Ditcher ' + i
            );
            jobSearchList.add(bulkSearchInsert);
        }
        try {
            insert jobSearchList;
            Assert.fail('Expected failure over 50 at once.');
        } catch(Exception e) {
            Assert.isTrue(e.getMessage().contains('Object Limit Exceeded: Only 50 Search Criteria may be modified at a time.'), 'Expected failure over 50 at once.');
        }
    }
    @isTest
    static void testInsertingDuplicate(){
        JobSearchCriteria__c defaultSearch = new JobSearchCriteria__c(
            IsActive__c = true,
            StatePick__c = 'Maryland',
            City__c = 'Accident',
            JobTitle__c = 'Digital Overlord'
        );
        try {
            insert defaultSearch;
            Assert.fail('Expected failure duplicate value found.');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('DUPLICATE_VALUE, duplicate value found:'), 'Expected failure duplicate value found.');
        }
    }
    @TestSetup
    static void makeData(){
        JobSearchCriteria__c defaultSearch = new JobSearchCriteria__c(
            IsActive__c = true,
            StatePick__c = 'Maryland',
            City__c = 'Accident',
            JobTitle__c = 'Digital Overlord'
        );
        insert defaultSearch;
    }
}
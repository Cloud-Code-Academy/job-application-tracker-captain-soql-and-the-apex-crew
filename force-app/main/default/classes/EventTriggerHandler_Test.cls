@isTest
public with sharing class EventTriggerHandler_Test {
    @isTest
    static void testNoOverlapButOtherEvents() {
        Event newEvent = new Event(
            StartDateTime = Datetime.now() + 4,
            EndDateTime = Datetime.now() + 6
        );
        insert newEvent;
        Assert.areEqual(2, [SELECT Id FROM Event].size(), 'Expected two events created.');
    }
    @isTest
    static void testOverlapWithOtherEvents() {
        Event newEvent = new Event(
            StartDateTime = Datetime.now() + 2,
            EndDateTime = Datetime.now() + 4
        );
        try{
            insert newEvent;
            //https://salesforce.stackexchange.com/questions/128686/how-do-i-cover-adderror-in-test-class
            //Cover add error in test class searching
        }catch (Exception e){
            
            Assert.areEqual(e.getCause(), 'You have another scheduled event at this time.', 'Expected failure due to overlap.');
        }
        //https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_System_Assert.htm#apex_System_Assert_fail
        //Assert.fail('Expected failure due to overlap.');
    }
    @TestSetup
    static void makeData() {
        Account acc = new Account(
            Name = 'Mars'
        );
        insert acc;
        JobPosting__c jobPost = new JobPosting__c(
            CompanyRef__c = acc.Id,
            Name = 'Repair Technician'
        );
        insert jobPost;
        JobApplication__c jobApp = new JobApplication__c(
            Account__c = acc.Id,
            Name = 'I\'m thinking this should be an Autonumber now...',
            JobPostingRef__c = jobPost.Id
        );
        insert jobApp;
        Event newEvent = new Event(
            StartDateTime = Datetime.now() + 1,
            EndDateTime = Datetime.now() + 3
        );
        insert newEvent;
    }
}
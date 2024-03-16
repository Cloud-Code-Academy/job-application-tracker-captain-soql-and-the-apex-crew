@isTest
public with sharing class EventTriggerHandler_Test {
    @isTest
    static void testNoOverlapButOtherEvents() {
        Event newEvent = new Event(
            StartDateTime = Datetime.newInstance(2124,6,19,13,15,2),
            EndDateTime = Datetime.newInstance(2124,6,19,13,45,2)
        );
        insert newEvent;
        Assert.areEqual(2, [SELECT Id FROM Event].size(), 'Expected two events created.');
    }
    @isTest
    static void testOverlapWithOtherEvents() {
        Event newEvent = new Event(
            StartDateTime = Datetime.newInstance(2124,6,19,12,45,2),
            EndDateTime = Datetime.newInstance(2124,6,19,13,30,2)
        );
        try {
            insert newEvent;
        } catch (Exception ex) {
            Boolean expectedExceptionThrown = ex.getMessage().contains('You have another scheduled event at this time.');
            Assert.areEqual(true, expectedExceptionThrown, 'Expected failure due to overlapping custom exception.');
        }
    }
    @isTest
    static void testOnAWeekend() {
        Event newEvent = new Event(
            StartDateTime = Datetime.newInstance(2124,6,25,12,45,2),
            EndDateTime = Datetime.newInstance(2124,6,25,13,30,2)
        );
        try {
            insert newEvent;
        } catch (Exception ex) {
            Boolean expectedExceptionThrown = ex.getMessage().contains('This is your off day, stop working. Unlike the people who made this.');
            Assert.areEqual(true, expectedExceptionThrown, 'Expected failure due to weekend custom exception.');
        }
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
            StartDateTime = Datetime.newInstance(2124,6,19,12,30,2),
            EndDateTime = Datetime.newInstance(2124,6,19,13,00,2)
        );
        insert newEvent;
    }
}
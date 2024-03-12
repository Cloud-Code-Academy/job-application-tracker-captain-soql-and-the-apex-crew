@isTest
public with sharing class JobApplicationTriggerHandler_Test {
    @isTest
    static void testDefaultInsert() {
        List<Task> taskOnJobApp = [SELECT Id FROM Task];
        Assert.areEqual(3, taskOnJobApp.size(), 'Expected three task to be created in the system from the default status');
    }
    @isTest
    static void testUpdateAndReverting(){
        JobApplication__c jobApp = [SELECT Id, Status__c FROM JobApplication__c];
        jobApp.status__c = 'Applying';
        update jobApp;
        jobApp.status__c = 'Saved';
        update jobApp;
        Assert.areEqual(8, [SELECT Id FROM Task].size(),  'Should be 8 task total despite going back to previous stage');
        Assert.areEqual('Saved', [SELECT Status__c FROM JobApplication__c][0].Status__c, 'Status should be Saved');
    }
    @isTest
    static void testAllTaskCreation(){
        JobApplication__c jobApp = [SELECT Id, Status__c FROM JobApplication__c];
        jobApp.status__c = 'Applying';
        update jobApp;
        jobApp.status__c = 'Applied';
        update jobApp;
        jobApp.status__c = 'Interviewing';
        update jobApp;
        jobApp.status__c = 'Negotiating';
        update jobApp;
        jobApp.status__c = 'Accepted';
        update jobApp;
        jobApp.status__c = 'Closed';
        update jobApp;
        Assert.areEqual(25,  [SELECT Id FROM Task].size(), 'Expected 25 total task to be created.');
    }
    @isTest 
    static void testInsertWithPrimaryContact_shouldProceedWithNoChanges() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        JobPosting__c jobPost = [SELECT Id FROM JobPosting__c LIMIT 1];
        JobApplication__c jobApp = new JobApplication__c();
        jobApp.JobPostingRef__c = jobPost.Id;
        jobApp.Contact__c = contact.Id;
        
        Test.startTest();
        insert jobApp;
        Test.stopTest();

        Assert.areEqual(contact.Id, jobApp.Contact__c, 'Expected the Primary Contact to be unmodified');
    }
    @isTest
    static void testAssignWithoutPrimaryContactOnInsert_shouldSetPrimaryContactToCompanyContact() {
        Account company = [SELECT Id FROM Account LIMIT 1];
        Contact contact = [SELECT Id, AccountId FROM Contact LIMIT 1];
        contact.AccountId = company.Id;
        update contact;
        JobPosting__c jobPost = [SELECT Id FROM JobPosting__c LIMIT 1];
        JobApplication__c jobApp = new JobApplication__c();
        jobApp.JobPostingRef__c = jobPost.Id;
        jobApp.Account__c = company.Id;

        Test.startTest();
        insert jobApp;
        Test.stopTest();

        JobApplication__c result = [SELECT Id, Contact__c FROM JobApplication__c WHERE Id = :jobApp.Id];

        Assert.areEqual(contact.Id, result.Contact__c, 'Expected the Primary Contact to be updated through Company relationship');
    }
    @isTest
    private static void testAssignmentWithoutPrimaryContactOnUpdate_shouldSetPrimaryContactFromRelatedContacts() {
        Account company = [SELECT Id FROM Account LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        JobPosting__c jobPost = [SELECT Id FROM JobPosting__c LIMIT 1];
        JobApplication__c jobApp = new JobApplication__c();
        jobApp.JobPostingRef__c = jobPost.Id;
        insert jobApp;

        JobApplication__c preUpdateJobApp = [SELECT Id, Contact__c FROM JobApplication__c WHERE Id = :jobApp.Id];
        Assert.isNull(preUpdateJobApp.Contact__c, 'Job application Primary Contact should not be populated at this point');

        ContactAssociation__c contactAssociation = new ContactAssociation__c();
        contactAssociation.JobApplication__c = jobApp.Id;
        contactAssociation.Contact__c = contact.Id;
        insert contactAssociation;

        Test.startTest();
        update jobApp;
        Test.stopTest();

        JobApplication__c postUpdateJobApp = [SELECT Id, Contact__c FROM JobApplication__c WHERE Id = :jobApp.Id];
        Assert.areEqual(contact.Id, postUpdateJobApp.Contact__c, 'Expected primary contact to populate from related contact');
    }
    @isTest
    private static void testAssignmentWithoutPrimaryContactOnUpdate_shouldSetPrimaryContactFromRelatedAccount() {
        Account company = [SELECT Id FROM Account LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        JobPosting__c jobPost = [SELECT Id FROM JobPosting__c LIMIT 1];
        JobApplication__c jobApp = new JobApplication__c();
        jobApp.JobPostingRef__c = jobPost.Id;
        insert jobApp;

        JobApplication__c preUpdateJobApp = [SELECT Id, Contact__c FROM JobApplication__c WHERE Id = :jobApp.Id];
        Assert.isNull(preUpdateJobApp.Contact__c, 'Job application Primary Contact should not be populated at this point');

        contact.AccountId = company.Id;
        update contact;
        jobApp.Account__c = company.Id;

        Test.startTest();
        update jobApp;
        Test.stopTest();

        JobApplication__c postUpdateJobApp = [SELECT Id, Contact__c FROM JobApplication__c WHERE Id = :jobApp.Id];
        Assert.areEqual(contact.Id, postUpdateJobApp.Contact__c, 'Expected primary contact to populate from related contact');
    }
    @IsTest
    private static void testAssignmentWithPrimaryContactOnUpdate_shouldProceedWithNoChanges() {
        // when
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        JobPosting__c jobPost = [SELECT Id FROM JobPosting__c LIMIT 1];
        JobApplication__c jobApp = new JobApplication__c();
        jobApp.JobPostingRef__c = jobPost.Id;
        jobApp.Contact__c = contact.Id;
        insert jobApp;

        JobApplication__c beforeUpdateJobApp = [SELECT Id, Contact__c FROM JobApplication__c WHERE Id = :jobApp.Id];
        
        Test.startTest();
        update jobApp;
        Test.stopTest();
        
        JobApplication__c afterUpdateJobApp = [SELECT Id, Contact__c FROM JobApplication__c WHERE Id = :jobApp.Id];

        Assert.areEqual(contact.Id, jobApp.Contact__c, 'Expected the Primary Contact match contact');
        Assert.areEqual(beforeUpdateJobApp.Contact__c, afterUpdateJobApp.Contact__c, 'Expected the Primary Contact to be unmodified');
    }
    @TestSetup
    static void makeData(){
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
        Contact contact = new Contact(LastName = 'Watney');
        insert contact;
    }
}
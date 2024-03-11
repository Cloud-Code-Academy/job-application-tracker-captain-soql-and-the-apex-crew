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
    static void setPrimaryContactTest_shouldPassWhenPrimaryContactPopulated() {
        JobApplication__c newJobApplication = [
            SELECT 
                Id, 
                Contact__c, 
                (SELECT 
                    Id, 
                    Contact__r.LastName 
                FROM JobApplications__r) 
            FROM JobApplication__c
        ];
        Assert.isNull(newJobApplication.Contact__c, 'Contact should be null to start');

        Contact newLocalContact = new Contact();
        newLocalContact.LastName = 'test local contact';
        insert newLocalContact;

        newJobApplication.Contact__c = newLocalContact.Id;
        update newJobApplication;

        Assert.isNotNull(newJobApplication.Contact__c, 'Expected Primary Contact on JobApplication');
        Contact singleContact = [SELECT Id FROM Contact WHERE Id != :newLocalContact.Id LIMIT 1];

        Test.startTest();
        JobApplicationTriggerHandler.setPrimaryContact(new Map<Id, JobApplication__c>{ 
            newJobApplication.id => newJobApplication
        });
        Test.stopTest();

        Assert.isNotNull(newJobApplication.Contact__c, 'Expected a primary contact to be updated');
        Assert.areNotEqual(singleContact.Id, newJobApplication.Contact__c, 'Expected assignment to maintain primary contact and not overwrite');
    }

    @isTest 
    static void setPrimaryContactTest_shouldPopulateEmptyPrimaryContactFromRelatedContacts() {
        JobApplication__c newJobApplication = [
            SELECT 
                Id, 
                Contact__c,
                Account__c, 
                (SELECT 
                    Id, 
                    Contact__r.LastName 
                FROM JobApplications__r) 
            FROM JobApplication__c
        ];

        Assert.isNull(newJobApplication.Contact__c, 'Expected empty Primary Contact on JobApplication');
        Contact singleContact = [SELECT Id FROM Contact WHERE LastName = 'Watney' LIMIT 1];

        ContactAssociation__c newContactAssociation = new ContactAssociation__c();
        newContactAssociation.Contact__c = singleContact.Id;
        newContactAssociation.JobApplication__c = newJobApplication.Id;
        insert newContactAssociation;

        newJobApplication = [
            SELECT 
                Id, 
                Contact__c,
                Account__c, 
                (SELECT 
                    Id, 
                    Contact__r.LastName 
                FROM JobApplications__r) 
            FROM JobApplication__c
        ];

        Test.startTest();
        JobApplicationTriggerHandler.setPrimaryContact(new Map<Id, JobApplication__c>{ 
            newJobApplication.id => newJobApplication
        });
        Test.stopTest();

        Assert.isNotNull(newJobApplication.Contact__c, 'Expected a primary contact to be updated');
        Assert.areEqual(singleContact.Id, newJobApplication.Contact__c, 'Expected assignment to only contact in org');
    }
    @IsTest
    private static void setPrimaryContactTest_shouldPopulateEmptyPrimaryContactFromContactFromCompany() {
        JobApplication__c newJobApplication = [
            SELECT 
                Id, 
                Account__c,
                Contact__c,
                (SELECT 
                    Id, 
                    Contact__r.LastName 
                FROM JobApplications__r) 
            FROM JobApplication__c
        ];

        Assert.isNull(newJobApplication.Contact__c, 'Expected empty Primary Contact on JobApplication to begin');

        Account companyTest = [SELECT Id FROM Account LIMIT 1];
        Assert.areEqual(companyTest.Id, newJobApplication.Account__c, 'Expected company to be available');

        Contact newContactFromCompany = new Contact();
        newContactFromCompany.FirstName = 'Test CompanyContact FirstName';
        newContactFromCompany.LastName = 'Test CompanyContact LastName';
        newContactFromCompany.AccountId = companyTest.Id;
        insert newContactFromCompany;

        Contact companyContact = [SELECT Id FROM Contact WHERE AccountId = :companyTest.Id LIMIT 1];
        Assert.isNotNull(companyContact, 'Expected matching Contact available through company');

        Test.startTest();
        JobApplicationTriggerHandler.setPrimaryContact(new Map<Id, JobApplication__c>{ 
            newJobApplication.id => newJobApplication
        });
        Test.stopTest();

        Assert.areEqual(companyContact.Id, newJobApplication.Contact__c, 'Expected to have Primary Contact assigned via company');
    }
    @IsTest 
    private static void setPrimaryContactTest_shouldNotCrashWhenNoOptionsAvailable() {
        JobApplication__c newJobApplication = [
            SELECT 
                Id, 
                Account__c,
                Contact__c,
                (SELECT 
                    Id, 
                    Contact__r.LastName 
                FROM JobApplications__r) 
            FROM JobApplication__c
        ];
        Assert.isNull(newJobApplication.Contact__c, 'Expected empty Primary Contact on JobApplication to begin');

        Test.startTest();
        JobApplicationTriggerHandler.setPrimaryContact(new Map<Id, JobApplication__c>{ 
            newJobApplication.id => newJobApplication
        });
        Test.stopTest();

        Assert.isNull(newJobApplication.Contact__c, 'Expected empty Primary Contact on JobApplication to be maintained');
    }

    // test class that inserts 400 JobApplications to test governor limits, should not fail.
    @IsTest
    private static void jobApplicationsBulkTest() {
        Integer numberToGenerate = 400;
        List<JobApplication__c> bulkJobApplicationList = new List<JobApplication__c>();
        JobPosting__c jobPost = [SELECT Id FROM JobPosting__c LIMIT 1];


        for (Integer i = 0; i < numberToGenerate; i++) {
            JobApplication__c newJobApplication = new JobApplication__c();
            newJobApplication.JobPostingRef__c = jobPost.Id;
            bulkJobApplicationList.add(newJobApplication);
        }

        Test.startTest();
        insert bulkJobApplicationList;
        Test.stopTest();

        for (JobApplication__c jobApp : bulkJobApplicationList) {
            Assert.isNull(jobApp.Contact__c, 'Expected empty contacts for bulk test');
        }

        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact companyContact = [
            SELECT Id, LastName
            FROM Contact
            WHERE LastName = 'Watney'
            LIMIT 1
        ];
        companyContact.AccountId = acc.Id;
        update companyContact;
        for (JobApplication__c jobApp : bulkJobApplicationList) {
            jobApp.Account__c = acc.Id;
        }

        // Test.startTest();
        update bulkJobApplicationList;
        // Test.stopTest();

        for (JobApplication__c jobApp : bulkJobApplicationList) {
            Assert.isNotNull(jobApp.Contact__c, 'Expected contacts to be populated after update');
        }

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
        Contact newContact = new Contact();
        newContact.FirstName = 'Mark';
        newContact.LastName = 'Watney';
        insert newContact;
    }
}
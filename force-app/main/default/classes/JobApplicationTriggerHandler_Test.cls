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
    @IsTest
    private static void testBulkInsert_updatePrimaryContactFromCompany() {
        Integer numberOfJobApplicationRecordsToInsert = 400;

        Account company = [SELECT Id FROM Account LIMIT 1];
        Contact contact = [SELECT Id, AccountId FROM Contact LIMIT 1];
        contact.AccountId = company.Id;
        update contact;
        JobPosting__c jobPost = [SELECT Id FROM JobPosting__c LIMIT 1];
        List<JobApplication__c> jobApplicationList = new List<JobApplication__c>();
        for (Integer i = 0; i < numberOfJobApplicationRecordsToInsert; i++) {
            JobApplication__c jobApp = new JobApplication__c();
            jobApp.JobPostingRef__c = jobPost.Id;
            jobApp.Account__c = company.Id;
            jobApplicationList.add(jobApp);
        }

        Test.startTest();
        insert jobApplicationList;
        Test.stopTest();

        List<JobApplication__c> queryResults = [SELECT Id, Contact__c FROM JobApplication__c WHERE Id IN :jobApplicationList];

        for (JobApplication__c insertedJobApp : queryResults) {
            Assert.areEqual(contact.Id, insertedJobApp.Contact__c, 'expected to update record to contact from company');
        }

    }
    @IsTest
    private static void testEstimatedTakeHomePayOnInsertAndUpdate_Single() {
            // Check for insert
        JobApplication__c jobApp = [
            SELECT Id, Name, Estimated_Yearly_Pay__c, Estimated_Monthly_Pay__c, Social_Security_Tax__c, Estimated_Federal_Tax__c, Medicare__c 
            FROM JobApplication__c 
            LIMIT 1
            ];
        
        Assert.areEqual(74950, jobApp.Estimated_Yearly_Pay__c, 'Yearly Pay should equal 74950');
        Assert.areEqual(6246, jobApp.Estimated_Monthly_Pay__c, 'Monthly Pay should equal 6246');
        Assert.areEqual(6200, jobApp.Medicare__c, 'Medicare should equal 6200');
        Assert.areEqual(1450, jobApp.Social_Security_Tax__c, 'Social Security should equal 1450');
        Assert.areEqual(17400, jobApp.Estimated_Federal_Tax__c, 'Monthley Pay should equal 17400');
    
            // update the salary and check again
        jobApp.Salary__c = 200000;
        
        Test.startTest() ;
        update jobApp;
        Test.stopTest() ;   

        jobApplication__c updatedJobApp = [ 
            SELECT Id, Name, Estimated_Yearly_Pay__c, Estimated_Monthly_Pay__c, Social_Security_Tax__c, Estimated_Federal_Tax__c, Medicare__c
            FROM jobApplication__c
            WHERE Id = :jobApp.Id
            ];

            // Asserts for update
        Assert.areEqual(149900, updatedJobApp.Estimated_Yearly_Pay__c, 'Yearly Pay should equal 149900');
        Assert.areEqual(12492,  updatedJobApp.Estimated_Monthly_Pay__c, 'Monthly Pay should equal 12492');
        Assert.areEqual(12400,  updatedJobApp.Medicare__c, 'Medicare should equal 12400');
        Assert.areEqual(2900,  updatedJobApp.Social_Security_Tax__c, 'Social Security should equal 2900');
        Assert.areEqual(34800,  updatedJobApp.Estimated_Federal_Tax__c, 'Monthly Pay should equal 34800');
    }
    @IsTest
    private static void testEstimatedTakeHomePayOnInsertAndUpdate_Bulk() {
               // Check for inserts
        List<JobApplication__c> jobApps = new List<JobApplication__c>();
        List<JobApplication__c> listOfUpdatedAppJobApps = new List<JobApplication__c>();
        Account  account = [SELECT Id, Name FROM Account LIMIT 1];
        JobPosting__c jobPost = [SELECT Id, Name FROM JobPosting__c LIMIT 1];

        for (Integer i = 0; i < 200; i++) {
            jobApps.add(new JobApplication__c(Name = 'fingerLickingJob' + i, Salary__c = 100000, JobPostingRef__c = jobPost.Id, Account__c = account.Id));
        }
        
        insert jobApps;
        
        // Query for all Job Applications
        List<JobApplication__c> insertedJobApps = [ 
            SELECT Id, Name, Estimated_Yearly_Pay__c, Estimated_Monthly_Pay__c, Social_Security_Tax__c, Estimated_Federal_Tax__c, Medicare__c
            FROM JobApplication__c
            WHERE Id IN :jobApps
            ];

            // Asserts
        Assert.areEqual(200, insertedJobApps.size(), 'Expected 200 job applications to be created');

        for (JobApplication__c jobApp : insertedJobApps) {
            Assert.areEqual(74950, jobApp.Estimated_Yearly_Pay__c, 'Yearly Pay should equal 74950');
            Assert.areEqual(6246,  jobApp.Estimated_Monthly_Pay__c, 'Monthly Pay should equal 6246');
            Assert.areEqual(6200,  jobApp.Medicare__c, 'Medicare should equal 6200');
            Assert.areEqual(1450,  jobApp.Social_Security_Tax__c, 'Social Security should equal 1450');
            Assert.areEqual(17400, jobApp.Estimated_Federal_Tax__c, 'Monthley Pay should equal 17400');
        }

        for(JobApplication__c jobAppToUpdate : insertedJobApps){
            jobAppToUpdate.Salary__c = 200000;
            listOfUpdatedAppJobApps.add(jobAppToUpdate);
        }

        // Update the salary field on all the job applications
        Test.startTest() ;
        update listOfUpdatedAppJobApps; 
        Test.stopTest() ;

        List<jobApplication__c> updatedJobAppRetrieved = [ 
            SELECT Id, Name, Estimated_Yearly_Pay__c, Estimated_Monthly_Pay__c, Social_Security_Tax__c, Estimated_Federal_Tax__c, Medicare__c
            FROM jobApplication__c
            WHERE Id IN :listOfUpdatedAppJobApps
            ];
                // Asserts
            Assert.areEqual(200, insertedJobApps.size(), 'Expected 200 job applications to be created');
            
        for (JobApplication__c updatedJobApp : updatedJobAppRetrieved) {
            Assert.areEqual(149900, updatedJobApp.Estimated_Yearly_Pay__c, 'Yearly Pay should equal 149900');
            Assert.areEqual(12492,  updatedJobApp.Estimated_Monthly_Pay__c, 'Monthly Pay should equal 12492');
            Assert.areEqual(12400,  updatedJobApp.Medicare__c, 'Medicare should equal 12400');
            Assert.areEqual(2900,   updatedJobApp.Social_Security_Tax__c, 'Social Security should equal 2900');
            Assert.areEqual(34800,  updatedJobApp.Estimated_Federal_Tax__c, 'Monthly Pay should equal 34800');
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
            JobPostingRef__c = jobPost.Id,
            Salary__c = 100000
        );
        insert jobApp;
        Contact contact = new Contact(LastName = 'Watney');
        insert contact;
    }
}
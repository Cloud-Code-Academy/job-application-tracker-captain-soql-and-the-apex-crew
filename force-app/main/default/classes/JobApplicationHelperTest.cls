@isTest
private class JobApplicationHelperTest {
    @TestSetup
    static void makeData(){
        Account acc = new Account(Name = 'Account Test 1');
        insert acc;

        JobPosting__c newJobPosting = new JobPosting__c();
        newJobPosting.CompanyRef__c = acc.Id;
        insert newJobPosting;

        JobApplication__c newJobApplication = new JobApplication__c();
        newJobApplication.Name = 'Test Application';
        newJobApplication.Account__c = acc.Id;
        newJobApplication.JobPostingRef__c = newJobPosting.Id;
        insert newJobApplication;

        Contact newContact = new Contact();
        newContact.FirstName = 'Test FirstName';
        newContact.LastName = 'Test LastName';
        insert newContact;

        ContactAssociation__c newContactAssociation = new ContactAssociation__c();
        newContactAssociation.Contact__c = newContact.Id;
        newContactAssociation.JobApplication__c = newJobApplication.Id;
        insert newContactAssociation;
    }
    @isTest 
    static void setPrimaryContactTest_shouldPopulateEmptyPrimaryContact() {
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

        Assert.isNull(newJobApplication.Contact__c, 'Expected empty Primary Contact on JobApplication');
        Contact singleContact = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        JobApplicationHelper.setPrimaryContact(new Map<Id, JobApplication__c>{ 
            newJobApplication.id => newJobApplication
        });
        Test.stopTest();

        Assert.isNotNull(newJobApplication.Contact__c, 'Expected a primary contact to be updated');
        Assert.areEqual(singleContact.Id, newJobApplication.Contact__c, 'Expected assignment to only contact in org');
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
        Contact newLocalContact = new Contact();
        newLocalContact.LastName = 'test contact 2';
        insert newLocalContact;
        newJobApplication.Contact__c = newLocalContact.Id;
        update newJobApplication;

        Assert.isNotNull(newJobApplication.Contact__c, 'Expected empty Primary Contact on JobApplication');
        Contact singleContact = [SELECT Id FROM Contact WHERE Id != :newLocalContact.Id LIMIT 1];

        Test.startTest();
        JobApplicationHelper.setPrimaryContact(new Map<Id, JobApplication__c>{ 
            newJobApplication.id => newJobApplication
        });
        Test.stopTest();

        Assert.isNotNull(newJobApplication.Contact__c, 'Expected a primary contact to be updated');
        Assert.areNotEqual(singleContact.Id, newJobApplication.Contact__c, 'Expected assignment to maintain primary contact and not overwrite');
    }
}
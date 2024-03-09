@isTest
private class JobApplicationHelperTest {
    @TestSetup
    static void makeData(){
        Account acc = new Account(Name = 'Account Test 1');
        insert acc;

        JobPosting__c newJobPosting = new JobPosting__c();
        newJobPosting.CompanyRef__c = acc.Id;
        insert newJobPosting;
        
        Contact newContact = new Contact();
        newContact.FirstName = 'Test FirstName';
        newContact.LastName = 'Test LastName';
        insert newContact;

        // Contact newContactFromCompany = new Contact();
        // newContactFromCompany.FirstName = 'Test CompanyContact FirstName';
        // newContactFromCompany.LastName = 'Test CompanyContact LastName';
        // newContactFromCompany.AccountId = acc.Id;
        // insert newContactFromCompany;

        JobApplication__c newJobApplication = new JobApplication__c();
        newJobApplication.Name = 'Test Application';
        newJobApplication.Account__c = acc.Id;
        newJobApplication.JobPostingRef__c = newJobPosting.Id;
        insert newJobApplication;
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
        Contact singleContact = [SELECT Id FROM Contact WHERE LastName = 'Test LastName' LIMIT 1];

        ContactAssociation__c newContactAssociation = new ContactAssociation__c();
        newContactAssociation.Contact__c = singleContact.Id;
        newContactAssociation.JobApplication__c = newJobApplication.Id;
        insert newContactAssociation;

        // start
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
        // end

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

        Assert.isNotNull(newJobApplication.Contact__c, 'Expected Primary Contact on JobApplication');
        Contact singleContact = [SELECT Id FROM Contact WHERE Id != :newLocalContact.Id LIMIT 1];

        Test.startTest();
        JobApplicationHelper.setPrimaryContact(new Map<Id, JobApplication__c>{ 
            newJobApplication.id => newJobApplication
        });
        Test.stopTest();

        Assert.isNotNull(newJobApplication.Contact__c, 'Expected a primary contact to be updated');
        Assert.areNotEqual(singleContact.Id, newJobApplication.Contact__c, 'Expected assignment to maintain primary contact and not overwrite');
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
        JobApplicationHelper.setPrimaryContact(new Map<Id, JobApplication__c>{ 
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
        JobApplicationHelper.setPrimaryContact(new Map<Id, JobApplication__c>{ 
            newJobApplication.id => newJobApplication
        });
        Test.stopTest();

        Assert.isNull(newJobApplication.Contact__c, 'Expected empty Primary Contact on JobApplication to be maintained');
    }
}
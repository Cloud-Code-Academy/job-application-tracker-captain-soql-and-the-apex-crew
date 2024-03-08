@isTest
private class JobApplicationHelperTest {
    @isTest 
    static void setPrimaryContactTest() {
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

        Test.startTest();
        JobApplicationHelper.setPrimaryContact(new Map<Id, JobApplication__c>{ 
            newJobApplication.id => newJobApplication
        });
        Test.stopTest();
        JobApplication__c results = [SELECT Id, Contact__c FROM JobApplication__c LIMIT 1];
        Assert.isNotNull(results.Contact__c, 'Expected a primary contact to be updated');
    }
}
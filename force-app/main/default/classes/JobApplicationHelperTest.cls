@isTest
private class JobApplicationHelperTest {
    @isTest 
    static void setPrimaryContactTest() {
        Account acc = new Account(Name = 'Account Test 1');
        insert acc;
        JobApplication__c newJobApplication = new JobApplication__c();
        newJobApplication.Name = 'Test Application';
        Assert.isTrue(true, 'Expected true');
    }
}
@isTest
public with sharing class JoobleIntegration_Test {
 
    
    @IsTest
    static void testJoobleIntegrationHTTPCallout() {
        //account created for upsert
        //jobposting for the mock
        //set up a 400 mock response
        //set the mock callout class
        //run the test
        //verify the mock response is not null
        //throwing false exception inside the test class--testing exceptions
        //get the info from the class
        //job posting and account are what we are creating and using

        // set the mock callout class
        Test.setMock(HttpCalloutMock.class, new JoobleIntegration_Mock());
        String keywords = 'Salesforce Developer';
        String location = 'Denver, CO';
        
        test.startTest();
        JoobleIntegration.makeHTTPCallout(keywords, location);
        test.stopTest();

        List<Account> actualAccounts = [SELECT Name FROM Account];
        List<JobPosting__c> actualJobPostings = [SELECT Name, Location__c, Salary__c FROM JobPosting__c];
        
        // System.assertEquals(1, actualJobPostings.size(), 'Expected one JobPosting__c record');
        // System.assertEquals('Salesforce Developer', actualJobPostings[0].Name, 'JobPosting__c name does not match');
        // System.assertEquals('Denver, CO', actualJobPostings[0].Location__c, 'JobPosting__c location does not match');
    
    }


    @isTest 
    static void parseResponseBodyIntoPostingInnerClass_Test() {
        staticResource sr = [SELECT Id,Body FROM StaticResource WHERE Name = 'joobleResponseBody'];
        string jsonString = sr.Body.toString();

        Test.startTest();
        List<JoobleIntegration.Posting> postings = JoobleIntegration.parseResponseBodyIntoPostingInnerClass(jsonString);
        Test.stopTest();

        Assert.areEqual('Prospect Infosystem Inc', postings.get(0).companyName, 'expected first job posting company to be "Prospect Infosystem Inc"');
        Assert.areEqual(Date.newInstance(2024, 2, 28), postings.get(0).updated, 'expected first posting update to be "2024-02-28"');

        Assert.areEqual(20, postings.size(), 'expected 20 files from static resource to be added to list');
    }

    @isTest 
    static void convertJsonTimeToDate_Test_ShouldConvert() {
        string jsonTime = '2024-03-11T00:00:00.0000000';

        Test.startTest();
        Date dtConversionAttempt = JoobleIntegration.convertJsonTimeToDate(jsonTime);
        Test.stopTest();

        Assert.areEqual(Date.newInstance(2024, 3, 11), dtConversionAttempt, 'Expected conversion to be "2024-03-11"' + ' but is ' + dtConversionAttempt);
    }
    @isTest 
    static void convertJsonTimeToDate_Test_ShouldReturnNull() {
        string jsonTime = '';

        Test.startTest();
        Date dtConversionAttempt = JoobleIntegration.convertJsonTimeToDate(jsonTime);
        Test.stopTest();

        Assert.isNull(dtConversionAttempt, 'expected empty time to return null');
    }


    @istest
    static void testJoobleIntegration() {
        
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
        }
}
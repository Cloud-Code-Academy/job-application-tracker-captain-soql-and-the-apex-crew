@isTest
public with sharing class JoobleIntegration_Test {

    /*
    @IsTest
    static void testGetDummyJSONUserFromId() {
        // Create contact
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        
        // Register the mock callout class
        Test.setMock(HttpCalloutMock.class, new JoobleIntegration_Mock());
        
        // As this is a future method, we need to enclose it in Test.startTest() and Test.stopTest() to ensure it's executed in the test context.
        Test.startTest();
        JoobleIntegration.makeHTTPCallout(keywords, location); // Call the method with an example userId
        Test.stopTest();

        // After the stopTest, the future method will have run. Now we can check if the contact was created correctly.
        //System.assertEquals(200, res.getStatusCode());
    }
    */

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
    static void convertJsonTimeToDatetime_Test_ShouldConvert() {
        string jsonTime = '2024-03-11T00:00:00.0000000';

        Test.startTest();
        Date dtConversionAttempt = JoobleIntegration.convertJsonTimeToDatetime(jsonTime);
        Test.stopTest();

        Assert.areEqual(Date.newInstance(2024, 3, 11), dtConversionAttempt, 'Expected conversion to be "2024-03-11"' + ' but is ' + dtConversionAttempt);
    }
    @isTest 
    static void convertJsonTimeToDatetime_Test_ShouldReturnNull() {
        string jsonTime = '';

        Test.startTest();
        Date dtConversionAttempt = JoobleIntegration.convertJsonTimeToDatetime(jsonTime);
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
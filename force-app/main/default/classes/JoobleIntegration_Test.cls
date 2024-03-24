@isTest
public with sharing class JoobleIntegration_Test {

    @IsTest
    static void testJoobleIntegrationHTTPCallout() { 

        // set the mock callout class
        Test.setMock(HttpCalloutMock.class, new JoobleIntegration_Mock());
        String keywords = 'Salesforce Developer';
        String location = 'Denver, CO';

        Account acc1 = new Account(
            Name = 'Apex Informatics'
        );
        insert acc1;

        test.startTest();
        JoobleIntegration.makeHTTPCallout(keywords, location);
        test.stopTest();

        List<String> accountNames = new List<String>{'Prospect Infosystem Inc', 'Apex Informatics', 'Procare Solutions'};

        List<Account> actualAccounts = [SELECT Name FROM Account WHERE  Name = :accountNames];
        List<JobPosting__c> actualJobPostings = [SELECT Name, CompanyRef__c, JooblePostingId__c, Link__c, Location__c, Salary__c, Snippet__c, Source__c, Type__c, Updated__c FROM JobPosting__c];

        System.assertEquals(3, actualAccounts.size(), 'Expected 3 Account record');
        System.assertEquals(3, actualJobPostings.size(), 'Expected 3 JobPosting__c record');

        for(Account a : actualAccounts) {
            //System.assertEquals('Mars', actualAccounts[0].Name, 'Account name does not match');
            System.assertEquals('Prospect Infosystem Inc', actualAccounts[0].Name, 'Account name does not match');
            System.assertEquals('Apex Informatics', actualAccounts[1].Name, 'Account name does not match');
            System.assertEquals('Procare Solutions', actualAccounts[2].Name, 'Account name does not match');
            
            System.assertEquals('8542290820435711574', actualJobPostings[0].JooblePostingId__c, 'JobPosting__c title does not match');
            System.assertEquals('Salesforce Developer', actualJobPostings[1].Name, 'JobPosting__c name does not match');
            System.assertEquals('Denver, CO', actualJobPostings[1].Location__c, 'JobPosting__c location does not match');
        }
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
                Name = 'Prospect Infosystem Inc'
            );

            insert acc;

            JobPosting__c jobPost = new JobPosting__c(
                CompanyRef__c = acc.Id,
                Name = 'Repair Technician',
                JooblePostingId__c = '8542290820435711574'

            );
            JobPosting__c jobPost1 = new JobPosting__c(
                CompanyRef__c = acc.Id,
                Name = 'Repair Technician',
                JooblePostingId__c = '7826091234674837853');

            insert jobPost;
            insert jobPost1;

            JobApplication__c jobApp = new JobApplication__c(
                Account__c = acc.Id,
                Name = 'I\'m thinking this should be an Autonumber now...',
                JobPostingRef__c = jobPost.Id
            );
        }
}
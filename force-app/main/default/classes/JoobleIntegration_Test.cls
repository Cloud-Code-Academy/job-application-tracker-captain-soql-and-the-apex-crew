/**
 * @description       : 
 * @author            : @Fritz
 * @group             : Cohort2
 * @last modified on  : 03-16-2024
 * @last modified by  : @Fritz
**/

@isTest
public with sharing class JoobleIntegration_Test {

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
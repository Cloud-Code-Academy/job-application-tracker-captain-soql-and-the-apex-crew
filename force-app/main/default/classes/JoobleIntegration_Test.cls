/**
 * @description       : 
 * @author            : @Fritz
 * @group             : Cohort2
 * @last modified on  : 03-16-2024
 * @last modified by  : @Fritz
**/

@isTest
public with sharing class JoobleIntegration_Test {


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
@isTest
public with sharing class JobApplicationTriggerHandler_Test {
    @isTest
    public TestWithoutTaskAlready() {
        //Update status to Applying

        //Assert task count for Applying are there plus Saved
    }
    @isTest
    public TestWithTaskAlready(){
        //Due to default status Saved status should have been created already.

        //Update Status to ""

        //Update Status to "Saved"

        //Assert no additional task created 

    }
    @TestSetup
    static void makeData(){
        //Create test Account
        //Create test Job Posting
        //Create test Job Application
    }
}
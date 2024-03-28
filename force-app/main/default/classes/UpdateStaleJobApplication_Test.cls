@isTest
public with sharing class UpdateStaleJobApplication_Test {
    @isTest
    static void testBatchingUpdate(){
        Test.startTest();
        UpdateStaleJobApplication_Batch batch = new UpdateStaleJobApplication_Batch();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();

        List<JobApplication__c> updatedJobApp = [SELECT Id, Status__c FROM JobApplication__c WHERE Follow_Up_Date__c < LAST_N_DAYS:30];
        List<Task> createdTask = [SELECT Id, Subject FROM Task WHERE Subject = 'Closed By Automated Process'];

        for(JobApplication__c jobApp : updatedJobApp){
            Assert.areEqual('Closed', jobApp.Status__c, 'Expected status updated to Closed');
        }
        Assert.areEqual(updatedJobApp.size(), createdTask.size(), 'Expected equal amount of created task to automatically closed JobApps');
    }
    @isTest
    static void testSchedule(){
        Test.startTest();
        UpdateStaleJobApplication_Schedule scheduleJob = new UpdateStaleJobApplication_Schedule();
        String year = String.valueOf(Date.today().year() + 1);
        String cron = '0 0 0 15 3 ? ' + year;
        System.schedule('Test Schedule', cron, scheduleJob);
        scheduleJob.execute(null);
        Test.stopTest();

        List<JobApplication__c> updatedJobApp = [SELECT Id, Status__c FROM JobApplication__c WHERE Follow_Up_Date__c < LAST_N_DAYS:30];
        List<Task> createdTask = [SELECT Id, Subject FROM Task WHERE Subject = 'Closed By Automated Process'];

        for(JobApplication__c jobApp : updatedJobApp){
            Assert.areEqual('Closed', jobApp.Status__c, 'Expected status updated to Closed');
        }
        Assert.areEqual(updatedJobApp.size(), createdTask.size(), 'Expected equal amount of created task to automatically closed JobApps');
    }
    @TestSetup
    static void makeData(){
        Account acc = new Account(
            Name = 'Mars'
        );
        insert acc;
        JobPosting__c jobPost = new JobPosting__c(
            CompanyRef__c = acc.Id,
            Name = 'Repair Technician'
        );
        insert jobPost;
        Date todayMinus45 = Date.today() - 45;
        JobApplication__c jobApp = new JobApplication__c(
            Account__c = acc.Id,
            Name = 'I\'m thinking this should be an Autonumber now...',
            JobPostingRef__c = jobPost.Id,
            Follow_Up_Date__c = todayMinus45
        );
        insert jobApp;
    }
}
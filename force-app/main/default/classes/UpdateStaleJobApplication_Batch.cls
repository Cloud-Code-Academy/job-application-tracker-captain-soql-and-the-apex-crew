public class UpdateStaleJobApplication_Batch implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Status__c, CreatedById ';
        query += 'FROM JobApplication__c ';
        query += 'WHERE Status__c != \'Closed\' ';
        query += 'AND Follow_up_date__c > LAST_N_DAYS:30';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<JobApplication__c> scope) {
        List<Task> tasksToCreate = new List<Task>();
        for(JobApplication__c jobApp : scope){
            jobApp.Status__c = 'Closed';
            Task newTask = new Task(
                WhatId = jobApp.Id,
                Subject = 'Closed By Automated Process',
                Status = 'Completed',
                OwnerId = jobApp.CreatedById
            );
            tasksToCreate.add(newTask);
        }
        update as system scope;
        insert as system tasksToCreate;
    }

    public void finish(Database.BatchableContext bc){
        System.debug('Executing secret function...');
        System.debug('Muahahahahahahahahaha!!');
        System.debug('You have no idea what you have started!');
    }
}
public with sharing class JobApplicationTriggerHandler {

    public static void createTaskBasedOnStatus(List<JobApplication__c> triggerDotNew) {
        Map<Id, List<String>> jobApplicationIdToTaskMap = createJobApplicationToTaskMap(triggerDotNew);
        List<Task> tasksToInsert = new List<Task>();
        Map<String, List<String>> statusToSubjectMap = createSubjectMap();
        for(JobApplication__c jobApp: triggerDotNew){
            for(String subject: statusToSubjectMap.get(jobApp.status__c)){
                if(!jobApplicationIdToTaskMap.get(jobApp.Id).contains(subject)){
                    tasksToInsert.add(setTaskToCreate(jobApp.Id, subject));
                }
            }
        }
        insert as user tasksToInsert;
    }

    public static void assignPrimaryContactOnInsert(List<JobApplication__c> triggerDotNew) {
        List<Id> accountIds = pluckAccountIds(triggerDotNew);
        Map<Id, Id> accountIdToContactIdMap = getAccountIdToContactIdMap(accountIds);

        for (JobApplication__c jobApp : triggerDotNew) {
            if (jobApp.Contact__c != null) {
                continue;
            } else if (hasCompanyRef(jobApp) && hasContactLinkedToCompanyRef(jobApp.Account__c, accountIdToContactIdMap)) {
                jobApp.Contact__c = accountIdToContactIdMap.get(jobApp.Account__c);
            }
        }
    }

    public static void assignPrimaryContactOnUpdate(List<JobApplication__c> triggerDotNew) {
        for (JobApplication__c jobApp : triggerDotNew) {
            if (jobApp.Contact__c != null) {
                continue;
            } else if (hasRelatedContacts(jobApp)) {
                jobApp.Contact__c = getFirstRelatedContact(jobApp);
            }
        }
    }

    // need to bulkify
    private static Boolean hasRelatedContacts (JobApplication__c jobApplication) {
        ContactAssociation__c contactAssociation = [SELECT Id, Contact__c FROM ContactAssociation__c WHERE JobApplication__c = :jobApplication.Id LIMIT 1];
        return contactAssociation != null;
    }

    // need to bulkify
    private static Id getFirstRelatedContact (JobApplication__c jobApplication) {
        return [SELECT Id, Contact__c FROM ContactAssociation__c WHERE JobApplication__c = :jobApplication.Id LIMIT 1].Contact__c;
    }

    private static Map<Id, List<String>> createJobApplicationToTaskMap(List<JobApplication__c> triggerDotNew){
        Map<Id, List<String>> jobApplicationIdToTaskMap = new Map<Id, List<String>>();
        for(JobApplication__c jobApp: triggerDotNew){
            jobApplicationIdToTaskMap.put(jobApp.Id, new List<String>());
        }
        for(Task tas: [SELECT Id, Subject,WhatId FROM Task WHERE WhatId In: triggerDotNew WITH USER_MODE]){
            jobApplicationIdToTaskMap.get(tas.WhatId).add(tas.Subject);
        }
        return jobApplicationIdToTaskMap;
    }

    private static Task setTaskToCreate(Id jobAppId, String subject){
        Task newTask = new Task(
            WhatId = jobAppId,
            Subject = subject,
            ActivityDate = Date.today() +1
        );
        return newTask;
    }
    
    private static Map<String,List<String>> createSubjectMap(){
        Map<String,List<String>> statusToSubjectMap = new Map<String,List<String>>();
        statusToSubjectMap.put('Saved', new List<String>{
            'Check if the job description aligns with your interests and values',
            'Review the highlighted skills to see if the role is a good fit',
            'Research the company or role and mark your excitement level'
        });
        statusToSubjectMap.put('Applying', new List<String>{
            'Find and research someone who works at the company and add them as a contact',
            'Set up an informational interview to learn more about the role/company',
            'Identify potential referrals to help get your application on the top of the pile',
            'Customize your work achievements using the job description keywords',
            'Submit your application on the company website if possible'
        });
        statusToSubjectMap.put('Applied', new List<String>{
            'Reach out to the hiring manager or recruiter',
            'Follow up on your application via email weekly',
            'Continue identifying and saving similar job opportunities',
            'Set up weekly networking calls to explore similar companies/roles'
        });
        statusToSubjectMap.put('Interviewing', new List<String>{
            'Prepare your blurb or “tell me about yourself” response',
            'Practice answering behavioral interview questions',
            'Research the company and your interviewers',
            'Set up your virtual interview space and test your tech',
            'Send thank you emails within 24 hours'
        });
        statusToSubjectMap.put('Negotiating', new List<String>{
            'Research your market value and know your numbers',
            'Prepare your negotiation scripts',
            'Evaluate your offer and decline or accept'
        });
        statusToSubjectMap.put('Accepted', new List<String>{
            'Plan your resignation if applicable',
            'Take some time to relax and recharge',
            'Prepare for your first day of onboarding'
        });
        statusToSubjectMap.put('Closed', new List<String>{
            'Send a follow-up email thanking the interviewer and asking for feedback',
            'Review your notes and reflect on areas of improvement'
        });
        return statusToSubjectMap;
    }

    private static List<Id> pluckAccountIds(List<JobApplication__c> JobApplications) {
        List<Id> accountIds = new List<Id>();
        for(JobApplication__c jobApp : JobApplications) {
            if (jobApp.Account__c != null) {
                accountIds.add(jobApp.Account__c);
            }
        }
        return accountIds;
    }

    private static Map<Id, Id> getAccountIdToContactIdMap(List<Id> accountIds) {
        Map<Id, Id> accountIdToContactIdMap = new Map<Id, Id>();
        for(Contact companyContact : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds]) {
            accountIdToContactIdMap.put(companyContact.AccountId, companyContact.Id);
        }
        return accountIdToContactIdMap;
    }

    private static Boolean hasCompanyRef(JobApplication__c jobApp) {
        return jobApp.Account__c != null;
    }

    private static Boolean hasContactLinkedToCompanyRef(Id companyIdFromJobApp, Map<Id, Id> accountIdToContactIdMap) {
        return accountIdToContactIdMap.get(companyIdFromJobApp) != null;
    }
}
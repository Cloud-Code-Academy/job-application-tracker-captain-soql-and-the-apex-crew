public with sharing class JobApplicationTriggerHandler {
    public static void createTaskBasedOnStatus(List<JobApplication__c> triggerDotNew) {

        Map<Id, List<String>> jobApplicationToTaskMap = new Map<Id, List<String>>();
        for(JobApplication__c jobApp: TriggerDotNew){
            JobApplicationToTaskMap.put(jobApp.Id, new List<String>());
        }
        for(Task tas: [SELECT Id, Subject,WhatId FROM Task WHERE WhatId In: triggerDotNew WITH USER_MODE]){
            JobApplicationToTaskMap.get(tas.WhatId).add(tas.Subject);
        }
        List<Task> tasksToInsert = new List<Task>();
        for(JobApplication__c jobApp: triggerDotNew){
            switch on jobApp.status__c{
                when 'Saved' {
                    FINAL List<String> SAVED_STATUS_SUBJECTS = new List<String>{
                        'Check if the job description aligns with your interests and values',
                        'Review the highlighted skills to see if the role is a good fit',
                        'Research the company or role and mark your excitement level'
                    };
                    for(String subject: SAVED_STATUS_SUBJECTS){
                        if(!jobApplicationToTaskMap.get(jobApp.Id).contains(subject)){
                            tasksToInsert.add(assignTaskToCreate(jobApp.Id, subject));
                        }
                    }
                }
                when 'Applying'{
                    FINAL List<String> APPLYING_SUBJECTS = new List<String>{
                        'Find and research someone who works at the company and add them as a contact',
                        'Set up an informational interview to learn more about the role/company',
                        'Identify potential referrals to help get your application on the top of the pile',
                        'Customize your work achievements using the job description keywords',
                        'Submit your application on the company website if possible'
                    };
                    for(String subject: APPLYING_SUBJECTS){
                        if(!jobApplicationToTaskMap.get(jobApp.Id).contains(subject)){
                            tasksToInsert.add(assignTaskToCreate(jobApp.Id, subject));
                        }
                    }
                }
                when 'Applied'{
                    FINAL List<String> APPLIED_SUBJECTS = new List<String>{
                        'Reach out to the hiring manager or recruiter',
                        'Follow up on your application via email weekly',
                        'Continue identifying and saving similar job opportunities',
                        'Set up weekly networking calls to explore similar companies/roles'
                    };
                    for(String subject: APPLIED_SUBJECTS){
                        if(!jobApplicationToTaskMap.get(jobApp.Id).contains(subject)){
                            tasksToInsert.add(assignTaskToCreate(jobApp.Id, subject));
                        }
                    }
                }
                when 'Interviewing'{
                    FINAL List<String> INTERVIEWING_SUBJECTS = new List<String>{
                        'Prepare your blurb or “tell me about yourself” response',
                        'Practice answering behavioral interview questions',
                        'Research the company and your interviewers',
                        'Set up your virtual interview space and test your tech',
                        'Send thank you emails within 24 hours'
                    };
                    for(String subject: INTERVIEWING_SUBJECTS){
                        if(!jobApplicationToTaskMap.get(jobApp.Id).contains(subject)){
                            tasksToInsert.add(assignTaskToCreate(jobApp.Id, subject));
                        }
                    }
                }
                when 'Negotiating'{
                    FINAL List<String> NEGOTIATING_SUBJECTS = new List<String>{
                        'Research your market value and know your numbers',
                        'Prepare your negotiation scripts',
                        'Evaluate your offer and decline or accept'
                    };
                    for(String subject: NEGOTIATING_SUBJECTS){
                        if(!jobApplicationToTaskMap.get(jobApp.Id).contains(subject)){
                            tasksToInsert.add(assignTaskToCreate(jobApp.Id, subject));
                        }
                    }
                }
                when 'Accepted'{
                    FINAL List<String> ACCEPTED_SUBJECTS = new List<String>{
                        'Plan your resignation if applicable',
                        'Take some time to relax and recharge',
                        'Prepare for your first day of onboarding'
                    };
                    for(String subject: ACCEPTED_SUBJECTS){
                        if(!jobApplicationToTaskMap.get(jobApp.Id).contains(subject)){
                            tasksToInsert.add(assignTaskToCreate(jobApp.Id, subject));
                        }
                    }
                }
                when 'Closed'{
                    FINAL List<String> CLOSED_SUBJECTS = new List<String>{
                        'Send a follow-up email thanking the interviewer and asking for feedback',
                        'Review your notes and reflect on areas of improvement'
                    };
                    for(String subject: CLOSED_SUBJECTS){
                        if(!jobApplicationToTaskMap.get(jobApp.Id).contains(subject)){
                            tasksToInsert.add(assignTaskToCreate(jobApp.Id, subject));
                        }
                    }
                }
            }
        }
        insert as user tasksToInsert;
    }
    private static Task assignTaskToCreate(Id jobAppId, String subject){
        Task newTask = new Task(
            WhatId = jobAppId,
            Subject = subject,
            ActivityDate = Date.today() +1
        );
        return newTask;
    }
}
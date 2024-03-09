public with sharing class JobApplicationTriggerHandler {
    public static void createTaskBasedOnStatus(List<JobApplication__c> triggerDotNew) {
        FINAL List<String> SAVED_STATUS_SUBJECTS = new List<String>{
            'Check if the job description aligns with your interests and values',
            'Review the highlighted skills to see if the role is a good fit',
            'Research the company or role and mark your excitement level'
        };
        FINAL List<String> APPLYING_SUBJECTS = new List<String>{
            'Find and research someone who works at the company and add them as a contact',
            'Set up an informational interview to learn more about the role/company',
            'Identify potential referrals to help get your application on the top of the pile',
            'Customize your work achievements using the job description keywords',
            'Submit your application on the company website if possible'
        };
        FINAL List<String> APPLIED_SUBJECTS = new List<String>{
            'Reach out to the hiring manager or recruiter',
            'Follow up on your application via email weekly',
            'Continue identifying and saving similar job opportunities',
            'Set up weekly networking calls to explore similar companies/roles'
        };
        FINAL List<String> INTERVIEWING_SUBJECTS = new List<String>{
            'Prepare your blurb or “tell me about yourself” response',
            'Practice answering behavioral interview questions',
            'Research the company and your interviewers',
            'Set up your virtual interview space and test your tech',
            'Send thank you emails within 24 hours'
        };
        //Get the Tasks on the current Job Application for each in the trigger
        Map<Id, List<String>> jobApplicationToTaskMap = new Map<Id, List<String>>();
        for(JobApplication__c jobApp: TriggerDotNew){
            JobApplicationToTaskMap.put(jobApp.Id, new List<String>());
        }
        for(Task tas: [SELECT Id, Subject,WhatId FROM Task WHERE WhatId In: TriggerDotNew WITH USER_MODE]){
            JobApplicationToTaskMap.get(tas.WhatId).add(tas.Subject);
        }
        //Check the status
        List<Task> tasksToInsert = new List<Task>();
        for(JobApplication__c jobApp: triggerDotNew){
            switch on jobApp.status__c{
                when 'Saved' {
                    if(!(jobApplicationToTaskMap.get(jobApp.Id).sort() == SAVED_STATUS_SUBJECTS.sort())){
                        tasksToInsert.addAll(createTasksToCreate(jobApp.Id, SAVED_STATUS_SUBJECTS));
                    }
                }
                when 'Applying'{

                }
                when 'Applied'{

                }
                when 'Interviewing'{

                }
                when 'Negotiating'{

                }
                when 'Accepted'{

                }
                when 'Closed'{

                }
                when else {
                    jobApp.addError('This value does not exist!!!! You Broke it!!!!');
                }
            }
        }
        insert as User tasksToInsert;
    }
    private static List<Task> createTasksToCreate(Id jobAppId, List<String> subjects){
        List<Task> tasksToCreate = new List<Task>();
        Task newTask = new Task();
        for(String subject: subjects){
            newTask.WhatId = jobAppId;
            newTask.Subject = subject;
            newTask.ActivityDate = Date.today() + 1;
            tasksToCreate.add(newTask);
        }
        return tasksToCreate;
    }
}
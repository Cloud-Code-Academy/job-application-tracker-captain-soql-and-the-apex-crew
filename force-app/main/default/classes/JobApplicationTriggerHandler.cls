public with sharing class JobApplicationTriggerHandler {

    private static final double MEDICARE_TAX_RATE = 0.0620;
    private static final double SOCIAL_SECURITY_TAX = 0.0145;
    private static final double FEDERAL_TAX =0.174;

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
        Map<Id, Id> accountIdToContactIdMap = getAccountIdToContactIdMapFromJobApplicationList(triggerDotNew);

        for (JobApplication__c jobApp : triggerDotNew) {
            if (jobApp.Contact__c != null) {
                continue;
            } else if (hasCompanyRef(jobApp) && hasContactLinkedToCompanyRef(jobApp.Account__c, accountIdToContactIdMap)) {
                jobApp.Contact__c = accountIdToContactIdMap.get(jobApp.Account__c);
            }
        }
    }

    public static void assignPrimaryContactOnUpdate(List<JobApplication__c> triggerDotNew) {
        // generates a list of Ids that are missing a primary contact from a list of updated Job Applications
        List<Id> missingPrimaryContactJobApplicationIds = new List<Id>();
        for(JobApplication__c jobApp : triggerDotNew) {
            if (jobApp.Contact__c == null) {
                missingPrimaryContactJobApplicationIds.add(jobApp.Id);
            }
        }
        List<ContactAssociation__c> filteredContactAssociationList = [SELECT Id, Contact__c, JobApplication__c FROM ContactAssociation__c WHERE JobApplication__c IN :missingPrimaryContactJobApplicationIds];

        // generates a map of Job App Id to Contact Id from the filtered Id list Job Applications
        Map<Id, Id> jobApplicationIdToContactIdMap = new Map<Id, Id>();
        for (ContactAssociation__c contactAssociation : filteredContactAssociationList) {
            jobApplicationIdToContactIdMap.put(contactAssociation.JobApplication__c, contactAssociation.Contact__c);
        }

        Map<Id, Id> accountIdToContactIdMap = getAccountIdToContactIdMapFromJobApplicationList(triggerDotNew);

        // method logic
        for (JobApplication__c jobApp : triggerDotNew) {
            if (jobApp.Contact__c != null) {
                continue;
            } else if (isRelatedContactAvailable(jobApp.Id, jobApplicationIdToContactIdMap)) {
                jobApp.Contact__c = jobApplicationIdToContactIdMap.get(jobApp.Id);
            } else if (hasCompanyRef(jobApp) && hasContactLinkedToCompanyRef(jobApp.Account__c, accountIdToContactIdMap)) {
                jobApp.Contact__c = accountIdToContactIdMap.get(jobApp.Account__c);
            }
        }
    }

        // Calculate Take Home Pay
        public static void estimateTakeHomePay(List<JobApplication__c> triggerDotNew) {
            List<JobApplication__c> jobAppsWithSalaries = new List<JobApplication__c>();
            for(JobApplication__c jobApp : triggerDotNew) {
                if(jobApp.Salary__c != null) {
                    calculatePay(jobApp);
                    jobAppsWithSalaries.add(jobApp);
                }
            }
        }

    private static Map<Id, Id> getAccountIdToContactIdMapFromJobApplicationList(List<JobApplication__c> jobApplicationList) {
        List<Id> accountIds = getAccountIdsFromJobApplicationList(jobApplicationList);
        return getAccountIdToContactIdMap(accountIds);
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

    private static List<Id> getAccountIdsFromJobApplicationList(List<JobApplication__c> JobApplications) {
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

    private static Boolean isRelatedContactAvailable(Id jobAppId, Map<Id, Id> jobApplicationIdToContactIdMap) {
        return jobApplicationIdToContactIdMap.containsKey(jobAppId);
    }

    private static Boolean hasCompanyRef(JobApplication__c jobApp) {
        return jobApp.Account__c != null;
    }

    private static Boolean hasContactLinkedToCompanyRef(Id companyIdFromJobApp, Map<Id, Id> accountIdToContactIdMap) {
        return accountIdToContactIdMap.get(companyIdFromJobApp) != null;
    }


    private static void calculatePay(JobApplication__c jobApp) {
        double totalMedicare = MEDICARE_TAX_RATE * jobApp.Salary__c;
        double totalSocialSecurity = SOCIAL_SECURITY_TAX * jobApp.Salary__c;
        double totalFederalTax = FEDERAL_TAX * jobApp.Salary__c;

        // We combine all the taxes into one variable for simplicity
        double combineFederalAndMedicareAndSocialSecurity = totalFederalTax + totalMedicare + totalSocialSecurity;
        jobApp.Estimated_Yearly_Pay__c = jobApp.Salary__c - combineFederalAndMedicareAndSocialSecurity;
        jobApp.Estimated_Monthly_Pay__c = Math.round(jobApp.Estimated_Yearly_Pay__c / 12);  //rounding the monthly to get a clean number to work with
        jobApp.Medicare__c = totalMedicare;
        jobApp.Social_Security_Tax__c = totalSocialSecurity;
        jobApp.Estimated_Federal_Tax__c = totalFederalTax;
    }

    public static void updateJobApplicationWithJopPostInfo(List<JobApplication__c> triggerDotNew) {
        Map<String, JobApplication__c> jobPostingIdToApplicationMap = new Map<String, JobApplication__c>();
        for(jobApplication__c jobApplication : triggerDotNew) {
            if(jobApplication.JobPostingRef__c != null) {
                jobPostingIdToApplicationMap.put(jobApplication.JobPostingRef__c, jobApplication);
            }
        }
        populateApplicationFromPosting(jobPostingIdToApplicationMap);
    }
    
    private static void populateApplicationFromPosting( Map<String, JobApplication__c> jobPostingIdToApplicationMap) {
        Map<Id, JobPosting__c> jobPostingIdToPostingMap = new Map<Id, JobPosting__c> ( [SELECT Id, Snippet__c, CompanyRef__c, Name, Salary__c, Location__c FROM JobPosting__c WHERE Id IN :jobPostingIdToApplicationMap.keySet()]);
        Double salaryConvert;
        for(JobApplication__c jobapp : jobPostingIdToApplicationMap.values()) {
            if (jobPostingIdToPostingMap.containsKey(jobapp.JobPostingRef__c)) {
                JobPosting__c relatedJobPosting = jobPostingIdToPostingMap.get(jobapp.JobPostingRef__c);
                jobapp.Office_Location__c = relatedJobPosting?.Location__c?.left(63);
                jobapp.Account__c = relatedJobPosting.CompanyRef__c;
                jobapp.Position__c = relatedJobPosting?.Name;
                jobapp.Description__c = relatedJobPosting?.Snippet__c;
                jobapp.Follow_up_date__c = Date.today() + 1;
                if (relatedJobPosting?.Salary__c != null) {
                    try {
                        String myReplaceString = relatedJobPosting.Salary__c.replaceAll('[^.\\d]','');
                        salaryConvert = Decimal.valueOf(myReplaceString);
                        jobapp.Salary__c = salaryConvert;
                    } catch (Exception e) {
                        System.debug('No Salary Info: ' + e.getMessage());
                    }
                }
            }
        }
    }
}
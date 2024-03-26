@isTest
public with sharing class JobApplicationTriggerHandler_Test {

    @isTest
    static void testDefaultInsert() {
        List<Task> taskOnJobApp = [SELECT Id FROM Task];
        Assert.areEqual(3, taskOnJobApp.size(), 'Expected three task to be created in the system from the default status');
    }
    @isTest
    static void testUpdateAndReverting(){
        JobApplication__c jobApp = [SELECT Id, Status__c FROM JobApplication__c];
        jobApp.status__c = 'Applying';
        update jobApp;
        jobApp.status__c = 'Saved';
        update jobApp;
        Assert.areEqual(8, [SELECT Id FROM Task].size(),  'Should be 8 task total despite going back to previous stage');
        Assert.areEqual('Saved', [SELECT Status__c FROM JobApplication__c][0].Status__c, 'Status should be Saved');
    }
    @isTest
    static void testAllTaskCreation(){
        JobApplication__c jobApp = [SELECT Id, Status__c FROM JobApplication__c];
        jobApp.status__c = 'Applying';
        update jobApp;
        jobApp.status__c = 'Applied';
        update jobApp;
        jobApp.status__c = 'Interviewing';
        update jobApp;
        jobApp.status__c = 'Negotiating';
        update jobApp;
        jobApp.status__c = 'Accepted';
        update jobApp;
        jobApp.status__c = 'Closed';
        update jobApp;
        Assert.areEqual(25,  [SELECT Id FROM Task].size(), 'Expected 25 total task to be created.');
    }
    @isTest 
    static void testInsertWithPrimaryContact_shouldProceedWithNoChanges() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        JobPosting__c jobPost = [SELECT Id FROM JobPosting__c LIMIT 1];
        JobApplication__c jobApp = new JobApplication__c();
        jobApp.JobPostingRef__c = jobPost.Id;
        jobApp.Contact__c = contact.Id;
        
        Test.startTest();
        insert jobApp;
        Test.stopTest();

        Assert.areEqual(contact.Id, jobApp.Contact__c, 'Expected the Primary Contact to be unmodified');
    }
    @isTest
    static void testAssignWithoutPrimaryContactOnInsert_shouldSetPrimaryContactToCompanyContact() {
        Account company = [SELECT Id FROM Account LIMIT 1];
        Contact contact = [SELECT Id, AccountId FROM Contact LIMIT 1];
        contact.AccountId = company.Id;
        update contact;
        JobPosting__c jobPost = [SELECT Id FROM JobPosting__c LIMIT 1];
        JobApplication__c jobApp = new JobApplication__c();
        jobApp.JobPostingRef__c = jobPost.Id;
        jobApp.Account__c = company.Id;

        Test.startTest();
        insert jobApp;
        Test.stopTest();

        JobApplication__c result = [SELECT Id, Contact__c FROM JobApplication__c WHERE Id = :jobApp.Id];

        Assert.areEqual(contact.Id, result.Contact__c, 'Expected the Primary Contact to be updated through Company relationship');
    }
    @isTest
    private static void testAssignmentWithoutPrimaryContactOnUpdate_shouldSetPrimaryContactFromRelatedContacts() {
        Account company = [SELECT Id FROM Account LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        JobPosting__c jobPost = [SELECT Id FROM JobPosting__c LIMIT 1];
        JobApplication__c jobApp = new JobApplication__c();
        jobApp.JobPostingRef__c = jobPost.Id;
        insert jobApp;

        JobApplication__c preUpdateJobApp = [SELECT Id, Contact__c FROM JobApplication__c WHERE Id = :jobApp.Id];
        Assert.isNull(preUpdateJobApp.Contact__c, 'Job application Primary Contact should not be populated at this point');

        ContactAssociation__c contactAssociation = new ContactAssociation__c();
        contactAssociation.JobApplication__c = jobApp.Id;
        contactAssociation.Contact__c = contact.Id;
        insert contactAssociation;

        Test.startTest();
        update jobApp;
        Test.stopTest();

        JobApplication__c postUpdateJobApp = [SELECT Id, Contact__c FROM JobApplication__c WHERE Id = :jobApp.Id];
        Assert.areEqual(contact.Id, postUpdateJobApp.Contact__c, 'Expected primary contact to populate from related contact');
    }
    @isTest
    private static void testAssignmentWithoutPrimaryContactOnUpdate_shouldSetPrimaryContactFromRelatedAccount() {
        Account company = [SELECT Id FROM Account LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        JobPosting__c jobPost = [SELECT Id FROM JobPosting__c LIMIT 1];
        JobApplication__c jobApp = new JobApplication__c();
        jobApp.JobPostingRef__c = jobPost.Id;
        insert jobApp;

        JobApplication__c preUpdateJobApp = [SELECT Id, Contact__c FROM JobApplication__c WHERE Id = :jobApp.Id];
        Assert.isNull(preUpdateJobApp.Contact__c, 'Job application Primary Contact should not be populated at this point');

        contact.AccountId = company.Id;
        update contact;
        jobApp.Account__c = company.Id;

        Test.startTest();
        update jobApp;
        Test.stopTest();

        JobApplication__c postUpdateJobApp = [SELECT Id, Contact__c FROM JobApplication__c WHERE Id = :jobApp.Id];
        Assert.areEqual(contact.Id, postUpdateJobApp.Contact__c, 'Expected primary contact to populate from related contact');
    }
    @IsTest
    private static void testAssignmentWithPrimaryContactOnUpdate_shouldProceedWithNoChanges() {
        // when
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        JobPosting__c jobPost = [SELECT Id FROM JobPosting__c LIMIT 1];
        JobApplication__c jobApp = new JobApplication__c();
        jobApp.JobPostingRef__c = jobPost.Id;
        jobApp.Contact__c = contact.Id;
        insert jobApp;

        JobApplication__c beforeUpdateJobApp = [SELECT Id, Contact__c FROM JobApplication__c WHERE Id = :jobApp.Id];
        
        Test.startTest();
        update jobApp;
        Test.stopTest();
        
        JobApplication__c afterUpdateJobApp = [SELECT Id, Contact__c FROM JobApplication__c WHERE Id = :jobApp.Id];

        Assert.areEqual(contact.Id, jobApp.Contact__c, 'Expected the Primary Contact match contact');
        Assert.areEqual(beforeUpdateJobApp.Contact__c, afterUpdateJobApp.Contact__c, 'Expected the Primary Contact to be unmodified');
    }
    @IsTest
    private static void testBulkInsert_updatePrimaryContactFromCompany() {
        Integer numberOfJobApplicationRecordsToInsert = 400;

        Account company = [SELECT Id FROM Account LIMIT 1];
        Contact contact = [SELECT Id, AccountId FROM Contact LIMIT 1];
        contact.AccountId = company.Id;
        update contact;
        JobPosting__c jobPost = [SELECT Id FROM JobPosting__c LIMIT 1];
        List<JobApplication__c> jobApplicationList = new List<JobApplication__c>();
        for (Integer i = 0; i < numberOfJobApplicationRecordsToInsert; i++) {
            JobApplication__c jobApp = new JobApplication__c();
            jobApp.JobPostingRef__c = jobPost.Id;
            jobApp.Account__c = company.Id;
            jobApplicationList.add(jobApp);
        }

        Test.startTest();
        insert jobApplicationList;
        Test.stopTest();

        List<JobApplication__c> queryResults = [SELECT Id, Contact__c FROM JobApplication__c WHERE Id IN :jobApplicationList];

        for (JobApplication__c insertedJobApp : queryResults) {
            Assert.areEqual(contact.Id, insertedJobApp.Contact__c, 'expected to update record to contact from company');
        }

    }
    @IsTest
    private static void testEstimatedTakeHomePayOnInsertAndUpdate_Single() {
            // Check for insert
        JobApplication__c jobApp = [
            SELECT Id, Name, Estimated_Yearly_Pay__c, Estimated_Monthly_Pay__c, Social_Security_Tax__c, Estimated_Federal_Tax__c, Medicare__c 
            FROM JobApplication__c 
            LIMIT 1
            ];
        
        Assert.areEqual(74950, jobApp.Estimated_Yearly_Pay__c, 'Yearly Pay should equal 74950');
        Assert.areEqual(6246, jobApp.Estimated_Monthly_Pay__c, 'Monthly Pay should equal 6246');
        Assert.areEqual(6200, jobApp.Medicare__c, 'Medicare should equal 6200');
        Assert.areEqual(1450, jobApp.Social_Security_Tax__c, 'Social Security should equal 1450');
        Assert.areEqual(17400, jobApp.Estimated_Federal_Tax__c, 'Monthley Pay should equal 17400');
    
            // update the salary and check again
        jobApp.Salary__c = 200000;
        
        Test.startTest() ;
        update jobApp;
        Test.stopTest() ;   

        jobApplication__c updatedJobApp = [ 
            SELECT Id, Name, Estimated_Yearly_Pay__c, Estimated_Monthly_Pay__c, Social_Security_Tax__c, Estimated_Federal_Tax__c, Medicare__c
            FROM jobApplication__c
            WHERE Id = :jobApp.Id
            ];

            // Asserts for update
        Assert.areEqual(149900, updatedJobApp.Estimated_Yearly_Pay__c, 'Yearly Pay should equal 149900');
        Assert.areEqual(12492,  updatedJobApp.Estimated_Monthly_Pay__c, 'Monthly Pay should equal 12492');
        Assert.areEqual(12400,  updatedJobApp.Medicare__c, 'Medicare should equal 12400');
        Assert.areEqual(2900,  updatedJobApp.Social_Security_Tax__c, 'Social Security should equal 2900');
        Assert.areEqual(34800,  updatedJobApp.Estimated_Federal_Tax__c, 'Monthly Pay should equal 34800');
    }
    @IsTest
    private static void testEstimatedTakeHomePayOnInsertAndUpdate_Bulk() {
               // Check for inserts
        List<JobApplication__c> jobApps = new List<JobApplication__c>();
        List<JobApplication__c> listOfUpdatedAppJobApps = new List<JobApplication__c>();
        Account  account = [SELECT Id, Name FROM Account LIMIT 1];
        JobPosting__c jobPost = [SELECT Id, Name FROM JobPosting__c LIMIT 1];

        for (Integer i = 0; i < 200; i++) {
            jobApps.add(new JobApplication__c(Name = 'fingerLickingJob' + i, Salary__c = 100000, JobPostingRef__c = jobPost.Id, Account__c = account.Id));
        }
        
        insert jobApps;
        
        // Query for all Job Applications
        List<JobApplication__c> insertedJobApps = [ 
            SELECT Id, Name, Estimated_Yearly_Pay__c, Estimated_Monthly_Pay__c, Social_Security_Tax__c, Estimated_Federal_Tax__c, Medicare__c
            FROM JobApplication__c
            WHERE Id IN :jobApps
            ];

            // Asserts
        Assert.areEqual(200, insertedJobApps.size(), 'Expected 200 job applications to be created');

        for (JobApplication__c jobApp : insertedJobApps) {
            Assert.areEqual(74950, jobApp.Estimated_Yearly_Pay__c, 'Yearly Pay should equal 74950');
            Assert.areEqual(6246,  jobApp.Estimated_Monthly_Pay__c, 'Monthly Pay should equal 6246');
            Assert.areEqual(6200,  jobApp.Medicare__c, 'Medicare should equal 6200');
            Assert.areEqual(1450,  jobApp.Social_Security_Tax__c, 'Social Security should equal 1450');
            Assert.areEqual(17400, jobApp.Estimated_Federal_Tax__c, 'Monthley Pay should equal 17400');
        }

        for(JobApplication__c jobAppToUpdate : insertedJobApps){
            jobAppToUpdate.Salary__c = 200000;
            listOfUpdatedAppJobApps.add(jobAppToUpdate);
        }

        // Update the salary field on all the job applications
        Test.startTest() ;
        update listOfUpdatedAppJobApps; 
        Test.stopTest() ;

        List<jobApplication__c> updatedJobAppRetrieved = [ 
            SELECT Id, Name, Estimated_Yearly_Pay__c, Estimated_Monthly_Pay__c, Social_Security_Tax__c, Estimated_Federal_Tax__c, Medicare__c
            FROM jobApplication__c
            WHERE Id IN :listOfUpdatedAppJobApps
            ];
                // Asserts
            Assert.areEqual(200, insertedJobApps.size(), 'Expected 200 job applications to be created');
            
        for (JobApplication__c updatedJobApp : updatedJobAppRetrieved) {
            Assert.areEqual(149900, updatedJobApp.Estimated_Yearly_Pay__c, 'Yearly Pay should equal 149900');
            Assert.areEqual(12492,  updatedJobApp.Estimated_Monthly_Pay__c, 'Monthly Pay should equal 12492');
            Assert.areEqual(12400,  updatedJobApp.Medicare__c, 'Medicare should equal 12400');
            Assert.areEqual(2900,   updatedJobApp.Social_Security_Tax__c, 'Social Security should equal 2900');
            Assert.areEqual(34800,  updatedJobApp.Estimated_Federal_Tax__c, 'Monthly Pay should equal 34800');
        }
    }
    @isTest
    private static void testPopulateApplicationFromPosting(){
        JobApplication__c jobApp = [SELECT Position__c,Office_Location__c, Salary__c,Description__c  FROM JobApplication__c WHERE Account__r.Name = 'Mars' LIMIT 1][0];
        Assert.areEqual('Repair Technician', jobApp.Position__c, 'Expected Matching Titles.');
        Assert.areEqual('Habitable Zone, MR', jobApp.Office_Location__c, 'Expected Matching Locations.');
        Assert.areEqual(500, jobApp.Salary__c, 'Expected extracted salary.');
        Assert.areEqual('In this job you will be sent to Mars and need to repair ~~REDACTED~~', jobApp.Description__c, 'Expected extracted description');
    }
    @isTest
    private static void testWithVeryPoorlyMatchingData(){
        Account acc = new Account(Name = 'Infinity Books');
        insert acc;
        JobPosting__c jobPost = new JobPosting__c(
            CompanyRef__c = acc.Id,
            Name = 'Quantum Literaturist',
            JooblePostingId__c = '0000000000000000008',
            Location__c = 'Infinity Books resides at Timeless Avenue and Imagination Street, amidst downtown\'s vibrant energy. From its cozy corner by the city park, it beckons you to explore endless worlds of literature.',
            Snippet__c = generateLoremIpsum(),
            Salary__c = 'Join Infinity Books for competitive salaries, enticing benefits, and a commitment to nurturing talent. Explore your potential with us today!',
            Source__c = 'The edge of Infinity Job Board',
            Type__c = 'Full Time- for ALL TIME',
            Updated__c = datetime.newInstance(4000, 9, 99)
        );
        insert jobPost;
        JobApplication__c jobApp = new JobApplication__c(
            Account__c = acc.Id,
            Name = 'Why wait when you have Infinity',
            JobPostingRef__c = jobPost.Id
        );
        insert jobApp;

        JobApplication__c jobAppConfirmed = [SELECT Position__c,Office_Location__c, Salary__c,Description__c  FROM JobApplication__c WHERE Account__r.Name = 'Infinity Books' LIMIT 1][0];
        Assert.areEqual('Quantum Literaturist', jobAppConfirmed.Position__c, 'Expected Matching Titles.');
        //Suggested handling of data that can not be extracted from information given.
        Assert.areEqual( null, jobAppConfirmed.Office_Location__c, 'Expected Matching Locations.');
        //Suggested handling of data that can not be extracted from information given.
        Assert.areEqual( null , jobAppConfirmed.Salary__c, 'Expected extracted salary.');
        //The jobApp description field can hold more characters than the JobPost snippet so this shouldn't be a problem. 
        Assert.areEqual(generateLoremIpsum(), jobAppConfirmed.Description__c, 'Expected extracted description');
    }
    @TestSetup
    static void makeData(){
        Account acc = new Account(
            Name = 'Mars'
        );
        insert acc;
        JobPosting__c jobPost = new JobPosting__c(
            CompanyRef__c = acc.Id,
            Name = 'Repair Technician',
            JooblePostingId__c = '5524155181653306098',
            Location__c = 'Habitable Zone, MR',
            Snippet__c = 'In this job you will be sent to Mars and need to repair ~~REDACTED~~',
            Salary__c = '500 martian dollars',
            Source__c = 'Mars Job Board',
            Type__c = ' A Job',
            Updated__c = datetime.newInstance(3101, 6, 25)
        );
        insert jobPost;
        JobApplication__c jobApp = new JobApplication__c(
            Account__c = acc.Id,
            Name = 'I\'m thinking this should be an Autonumber now...',
            JobPostingRef__c = jobPost.Id,
            Salary__c = 100000
        );
        insert jobApp;
        Contact contact = new Contact(LastName = 'Watney');
        insert contact;
    }
    private static String generateLoremIpsum(){
        String loremIpsum = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed nec arcu nec odio fermentum laoreet. Vestibulum a sem quis mi placerat fermentum ac nec quam. Sed auctor, magna eget vestibulum sagittis, nulla ex efficitur purus, id hendrerit eros sapien sed leo. Vivamus quis commodo lorem. Morbi nec est at lorem varius mattis. Sed ut odio et metus convallis convallis vel ut leo. Pellentesque vitae metus nec nunc accumsan tincidunt nec a tellus. Integer a nunc mi. Cras vel mi nec lacus interdum pharetra a ac felis. In hac habitasse platea dictumst. Morbi id nisi vel metus dictum tincidunt. Phasellus nec dui id tellus hendrerit egestas. Nam faucibus ante non enim tincidunt, sit amet rhoncus urna pellentesque.';
        loremIpsum += '\n\nPraesent eu justo a arcu congue consectetur. Mauris nec libero ullamcorper, volutpat magna ac, fermentum est. Ut semper purus non nulla fringilla bibendum. Aliquam a velit eget urna lacinia cursus sed a leo. Donec id risus at magna posuere dignissim. Sed posuere est nec tortor aliquam gravida. Morbi vulputate auctor justo, ac dapibus nisi. Suspendisse potenti. Aliquam erat volutpat. Mauris sed erat a sapien dignissim sollicitudin. Vivamus sollicitudin, tortor id posuere vehicula, massa nisl mattis justo, nec aliquet eros arcu at velit. Morbi volutpat accumsan nulla, vel viverra leo feugiat a. Nam gravida consequat metus, vel vestibulum est feugiat a. Proin ut lacus id lorem pharetra mollis. Phasellus sodales orci nec lectus condimentum feugiat. Vestibulum quis malesuada nulla.';
        loremIpsum += '\n\nDuis tincidunt aliquam felis, non tincidunt odio laoreet sed. Pellentesque nec leo nec lacus tempor fermentum. Fusce volutpat tellus eget lacus lacinia, at bibendum dolor rhoncus. Integer eget leo efficitur, fermentum velit sed, hendrerit libero. Donec eget tempor ex. Cras placerat feugiat metus, eu ultricies urna mattis id. Nam in neque a purus tincidunt vulputate. Pellentesque quis nulla eget sem condimentum aliquet. Nullam nec tortor ultrices, efficitur ipsum eu, pulvinar nisi. Fusce bibendum arcu quis magna tincidunt dapibus. Ut feugiat nulla nec turpis suscipit, eget vehicula lacus vehicula. Nulla facilisi. Integer sit amet diam tellus. Phasellus nec turpis feugiat, tincidunt nisi eu, vulputate metus.';
        loremIpsum += '\n\nPhasellus at dictum dui. In at tincidunt ligula. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Nulla nec nisi dapibus, venenatis libero eget, rutrum magna. Mauris maximus, dolor vel placerat tincidunt, quam mi congue neque, nec faucibus odio leo at libero. Nam consequat magna vel nisi vulputate tempus. Nulla facilisi. Integer congue leo vitae finibus laoreet. Nulla facilisi. Nullam vehicula dolor in magna tempor blandit. Fusce ut commodo ex. Nulla facilisi. Suspendisse potenti. Etiam non magna at purus pretium efficitur. Nam elementum sit amet risus at aliquam. Donec vel massa vestibulum, consectetur libero sed, gravida neque. In sed tortor nisi.';
        loremIpsum += '\n\nPraesent non vestibulum mi. Cras interdum, metus vel dictum gravida, lectus odio vehicula leo, a gravida elit nulla vitae dui. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nulla eget purus nec nisi blandit posuere. Suspendisse potenti. Cras ut eros nec enim blandit dapibus. Fusce venenatis lacinia urna, id vehicula justo. Duis sit amet arcu vitae lorem tincidunt vehicula nec in nulla. Curabitur consectetur vel mi non convallis. Donec mattis risus id metus aliquet venenatis. Ut hendrerit mi vel metus vehicula, eget tempor justo faucibus. Integer vel velit in est hendrerit congue. Aliquam erat volutpat. In commodo velit a velit egestas, eget vehicula libero sollicitudin. Vivamus scelerisque ligula nec scelerisque consequat. Integer at dui id nulla ultrices consequat. Suspendisse ornare augue ut eros cursus, id dapibus velit eleifend.';
        loremIpsum += '\n\nVestibulum ullamcorper consectetur turpis, in vestibulum est aliquet vitae. In hac habitasse platea dictumst. Phasellus eget tortor ac mi tempor cursus. Cras vitae libero in lorem auctor venenatis. Vestibulum auctor varius leo id venenatis. Nullam tincidunt dapibus ligula, sit amet viverra magna facilisis eu. Sed nec ultricies tortor. Sed tempor nisl ac arcu convallis fermentum. Nulla at mauris in sapien convallis feugiat sit amet nec nisi. Vivamus vitae convallis lectus, eu vehicula urna. Integer faucibus ullamcorper sem, a rhoncus eros lobortis sit amet. Duis scelerisque nunc sed ante tempus, nec malesuada libero consequat. Integer a libero quis elit ullamcorper mattis.';
        loremIpsum += '\n\nNam lacinia metus at arcu facilisis, nec ultricies risus interdum. Sed laoreet malesuada nisl, a ultricies urna dapibus nec. Curabitur ultrices felis eu orci malesuada, a commodo elit aliquet. Pellentesque tincidunt euismod velit nec tincidunt. Aenean eleifend convallis eros, eu tincidunt justo. Aliquam fringilla vestibulum est id vulputate. Pellentesque vitae mi ut ex eleifend malesuada a sed metus. Vivamus a magna sapien. Donec id ligula non ipsum dignissim lobortis. Aliquam non interdum justo. In hac habitasse platea dictumst. Integer vel ultricies quam, ut suscipit turpis. Aenean vel justo nec nisi tincidunt eleifend. Maecenas vitae mi condimentum, consectetur enim non, convallis nisl. Integer eu magna quis tortor interdum accumsan. Integer hendrerit, ligula vel aliquam hendrerit, quam risus ullamcorper nulla, sed aliquet nisi risus';
        return loremIpsum;
    }
}
@isTest
private class UpcomingInterviewEmail_Schedule_Test {
    private static final Integer NUMBER_OF_TEST_INTERVIEWS_UPCOMING = 5;
    private static final Integer NUM_USERS_TO_CREATE = 3;
    private static final Id INTERVIEW_EVENT_RECORDTYPE_ID = [
        SELECT Id, Name 
        FROM RecordType 
        WHERE SobjectType = 'Event' AND Name = 'Interview' 
        LIMIT 1
    ].Id;
    private static final Integer HEADER_ROW = 1;
    private static final String DAILY_6AM = '0 0 6 * * ?';
    private static final String EMAIL_TARGET_FOR_TEST = 'testUser' + String.valueOf(DateTime.now().getTime()) + '@test.com';
    private static final Integer LOOK_AHEAD_NEXT_N_DAYS = 1;

    @TestSetup
    static void makeData(){
        // generate users, to attach jobs to
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1]; 
        String uniqueString = String.valueOf(DateTime.now().getTime());
        List<User> testUsers = new List<User>();
        for(Integer i = 0; i < NUM_USERS_TO_CREATE; i++) {
            User testUser = new User(
                Alias = 'TUser' + i,
                Username = 'testuser' + i + uniqueString + '@example.com',
                Email = EMAIL_TARGET_FOR_TEST,
                LastName = 'TestUser' + i,
                ProfileId = standardUserProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                IsActive = true
            );
            testUsers.add(testUser);
        }
        insert testUsers;

        List<Event> events = new List<Event>();
        for (User testUser : testUsers) {
            for (Integer i = 0; i < NUMBER_OF_TEST_INTERVIEWS_UPCOMING; i++) {
                Event newEvent = new Event(
                    Subject = 'Test Interview ' + i,
                    StartDateTime = DateTime.now().addDays(LOOK_AHEAD_NEXT_N_DAYS),
                    EndDateTime = Datetime.now().addDays(LOOK_AHEAD_NEXT_N_DAYS).addMinutes(30),
                    Location = 'Online',
                    OwnerId = testUser.Id,
                    RecordTypeId = INTERVIEW_EVENT_RECORDTYPE_ID
                );
                events.add(newEvent);
            }
        }
        insert events;
    }

    @isTest 
    static void schedulableLogic_Test_shouldSchedule() {
        Datetime tomorrowDateTime = Datetime.now().addDays(1);
        Datetime tomorrow6AMDateTime = Datetime.newInstance(
            tomorrowDateTime.year(), 
            tomorrowDateTime.month(), 
            tomorrowDateTime.day(), 
            6, 0, 0
        );

        UpcomingInterviewEmail_Schedule scheduleJob = new UpcomingInterviewEmail_Schedule();
        String jobId = System.schedule('InterviewsTomorrowEmailSummary', DAILY_6AM, scheduleJob);

        Test.startTest();
        scheduleJob.execute(null);
        Test.stopTest();

        CronTrigger jobEmailReminderId = [SELECT Id, NextFireTime FROM CronTrigger WHERE Id = :jobId];

        Assert.isNotNull(jobEmailReminderId, 'Scheduled job ID should not be null');
        Assert.areEqual(tomorrow6AMDateTime, jobEmailReminderId.NextFireTime, 'Expected next fire time to be tomorrow at 6am');
    }

    @isTest
    static void upcomingInterviewEmailGeneration_Test() {
        Id testUserId = [SELECT Id FROM User WHERE LastName LIKE '%testUser%' LIMIT 1].Id;
        String queryString = 'SELECT Id, OwnerId, Subject, StartDateTime, EndDateTime, Location, RecordTypeId FROM Event WHERE RecordTypeId = :INTERVIEW_EVENT_RECORDTYPE_ID AND OwnerId = :testUserId AND StartDateTime = NEXT_N_DAYS:' + LOOK_AHEAD_NEXT_N_DAYS;
        List<Event> eventsUpcomingList = Database.query(queryString);

        Test.startTest();
        Messaging.SingleEmailMessage resultEmail = UpcomingInterviewEmail_Schedule.generateEmail(testUserId, eventsUpcomingList);
        Test.stopTest();

        Assert.areEqual(
            NUMBER_OF_TEST_INTERVIEWS_UPCOMING + HEADER_ROW, 
            resultEmail.getHtmlBody().countMatches('<tr>'), 
            'The number of interview rows in the email should match the number of interviews tomorrow + 1 for header row.'
        );
        Assert.isTrue(resultEmail.toaddresses.contains(testUserId), 'Email is missing user in To: field');
        Assert.isTrue(resultEmail.getSubject().contains('Interview Events Upcoming'), 'Expect email subject to contain text: "Interview Events Upcoming"');
    }
    @isTest
    private static void generateEventTable_Test() {
        User user = [
            SELECT Id 
            FROM User 
            WHERE LastName 
            LIKE '%testUser%' 
            LIMIT 1];
        List<Event> testEvents = [
            SELECT Id, StartDateTime, EndDateTime, OwnerId, Subject, Location 
            FROM Event 
            WHERE OwnerId = :user.Id
        ];
        Map<Id, List<Event>> ownerIdToEventsMap = new Map<Id, List<Event>>();
        
        Test.startTest();
        String eventTable = UpcomingInterviewEmail_Schedule.generateEventTable(testEvents);
        Test.stopTest();

        Assert.areEqual(
            NUMBER_OF_TEST_INTERVIEWS_UPCOMING + HEADER_ROW, 
            eventTable.countMatches('<tr>'), 
            'The number of interview rows in the email should match the number of interviews tomorrow + 1 for header row.'
        );
        Assert.IsTrue(eventTable.contains('<td>Online</td><td>Test Interview 1</td>'), 'Expected HTML table to output');
    }

    @isTest 
    static void generateOwnerIdToInterviewsMap_Test() {
        User testUser = [SELECT Id FROM User WHERE LastName LIKE '%testUser%' LIMIT 1];
        List<Event> events = [SELECT Id, OwnerId FROM Event];

        Test.startTest();
        Map<Id, List<Event>> resultsMap = UpcomingInterviewEmail_Schedule.generateOwnerIdToInterviewsMap(events);
        Test.stopTest();

        Assert.areEqual(NUMBER_OF_TEST_INTERVIEWS_UPCOMING, resultsMap.get((Id)testUser.Id).size(), 'expected events to be associated with the user that matched test constant');
    }

    @isTest
    private static void sendDailyInterviewEmailReminders_Test() {
        
        Test.startTest();
        UpcomingInterviewEmail_Schedule.sendDailyInterviewEmailReminders(NUMBER_OF_TEST_INTERVIEWS_UPCOMING);
        Assert.areEqual(1, Limits.getEmailInvocations(), 'expected a single instance to be created');
        Test.stopTest();

        List<EmailMessage> sentEmails = [SELECT Subject, ToAddress, HtmlBody FROM EmailMessage WITH USER_MODE];
        System.assertEquals(NUM_USERS_TO_CREATE, sentEmails.size(), 'Expected 1 email to be sent');
    }

    @isTest
    static void scheduleExecute_Test_shouldSchedule() {
        Test.startTest();
        String jobId = System.schedule('UpcomingInterviewEmail_Schedule Job', DAILY_6AM, new UpcomingInterviewEmail_Schedule());
        // Assert.areEqual(1, Limits.getEmailInvocations(), 'expected a single instance to be created');
        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger 
            WHERE id = :jobId
        ];
        Assert.areEqual(DAILY_6AM, ct.CronExpression, 'Time does not match');
        System.assertEquals(0, ct.TimesTriggered, 'did not expect the job to run');

        DateTime tomorrowDateTime = Datetime.now().addDays(1);
        Datetime tomorrow6AMDateTime = Datetime.newInstance(
            tomorrowDateTime.year(), 
            tomorrowDateTime.month(), 
            tomorrowDateTime.day(), 
            6, 0, 0
        );

        Assert.areEqual(tomorrow6AMDateTime, ct.NextFireTime, 'expected next fire time to be tomorrow at 6am');
        Test.stopTest();
    }
}
@isTest
private class UpcomingInterviewEmail_Schedule_Test {
    private static final Integer NUMBER_OF_TEST_INTERVIEWS_UPCOMING = 5;
    private static final Id INTERVIEW_EVENT_RECORDTYPE_ID = [
        SELECT Id, Name 
        FROM RecordType 
        WHERE SobjectType = 'Event' AND Name = 'Interview' 
        LIMIT 1
    ].Id;
    private static final Integer HEADER_ROW = 1;
    // Schedule the job to run daily at 6 AM
    private static final String DAILY_6AM = '0 0 6 * * ?';
    private static final String EMAIL_TARGET_FOR_TEST = 'testUser' + String.valueOf(DateTime.now().getTime()) + '@test.com';
    private static final Integer LOOK_AHEAD_NEXT_N_DAYS = 3;

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
    // @isTest 
    // static void schedulableLogic_Test_shouldFail() {
    //     Datetime tomorrowDateTime = Datetime.now().addDays(1);
    //     Datetime tomorrow6AMDateTime = Datetime.newInstance(
    //         tomorrowDateTime.year(), 
    //         tomorrowDateTime.month(), 
    //         tomorrowDateTime.day(), 
    //         6, 0, 0
    //     );

    //     generateInterviewsFromUserIdTestData(generateUserTestData());


    //     UpcomingInterviewEmail_Schedule scheduleJob = new UpcomingInterviewEmail_Schedule();

    //     String jobId = System.schedule('InterviewsTomorrowEmailSummary', DAILY_6AM, scheduleJob);
    //     try {
    //         Test.startTest();
    //         scheduleJob.execute(null);
    //         Test.stopTest();
            
    //         // Assert.fail('Email messages failed to deliver, failed to reach escape velocity');
    //     } catch (Exception ex) {
    //         Assert.isFalse(true, 'getMessage(): ' + ex.getMessage());
    //         Assert.isFalse(true, 'getStackTrackString(): ' + ex.getStackTraceString());
    //         Assert.isFalse(true, 'getCause(): ' + ex.getCause());
    //         Assert.isFalse(true, 'getTypeName(): ' + ex.getTypeName());
    //         Assert.isFalse(true, 'getNumDml(): ' + ex.getNumDml());
    //     }

    //     CronTrigger jobEmailReminderId = [SELECT Id, NextFireTime FROM CronTrigger WHERE Id = :jobId];

    //     Assert.isNotNull(jobEmailReminderId, 'Scheduled job ID should not be null');
    //     Assert.areEqual(tomorrow6AMDateTime, jobEmailReminderId.NextFireTime, 'Expected next fire time to be tomorrow at 6am');
    // }

    // @isTest 
    // private static List<User> generateUserTestData() {
    //     Id standardProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
    //     final Integer NUM_USERS_TO_CREATE = 51;
        
    //     List<User> users = new List<User>();
    //     String uniqueString = String.valueOf(DateTime.now().getTime());
    //     List<User> testUsers = new List<User>();
    //     for(Integer i = 0; i < NUM_USERS_TO_CREATE; i++) {
    //         User user = new User(
    //             LastName = 'TestUser' + i,
    //             FirstName = 'FirstName' + i,
    //             Email = 'testuser' + i + uniqueString + '@example.com',
    //             Username = 'testuser' + i + uniqueString + '@example.com',
    //             Alias = 'TUser' + i,
    //             ProfileId = standardProfileId,
    //             TimeZoneSidKey = 'America/Los_Angeles',
    //             LocaleSidKey = 'en_US',
    //             EmailEncodingKey = 'UTF-8',
    //             LanguageLocaleKey = 'en_US',
    //             IsActive = true
    //         );
    //         testUsers.add(user);
    //     }
        
    //     insert testUsers;
    //     return testUsers;
    // }
    // @isTest 
    // private static List<Event> generateInterviewsFromUserIdTestData(List<Id> testUserIds) {
    //     List<Event> events = new List<Event>();

    //     for (Id testUserId : testUserIds) {
    //         for (Integer i = 0; i < NUMBER_OF_TEST_INTERVIEWS_UPCOMING; i++) {
    //             Event newEvent = new Event(
    //                 Subject = 'Test Interview ' + i,
    //                 StartDateTime = DateTime.now().addDays(1),
    //                 EndDateTime = Datetime.now().addDays(1).addMinutes(30),
    //                 Location = 'Online',
    //                 OwnerId = testUserId,
    //                 RecordTypeId = INTERVIEW_EVENT_RECORDTYPE_ID
    //             );
    //             events.add(newEvent);
    //         }
    //     }
    //     insert events;
    // }



    @isTest
    static void upcomingInterviewEmailGeneration_Test() {
        User testUser = [SELECT Id FROM User WHERE LastName LIKE '%testUser%' LIMIT 1];
        String queryString = 'SELECT Id, OwnerId, Subject, StartDateTime, EndDateTime, Location, RecordTypeId FROM Event WHERE RecordTypeId = :INTERVIEW_EVENT_RECORDTYPE_ID AND StartDateTime = NEXT_N_DAYS:' + LOOK_AHEAD_NEXT_N_DAYS;

        List<Event> eventsUpcomingList = Database.query(queryString);
        // List<Event> eventsTomorrowList = [
        //     SELECT Id, OwnerId, Subject, StartDateTime, EndDateTime, Location, RecordTypeId
        //     FROM Event
        //     WHERE RecordTypeId = :INTERVIEW_EVENT_RECORDTYPE_ID
        //     AND StartDateTime = NEXT_N_DAYS:3
        // ];

        Test.startTest();
        Messaging.SingleEmailMessage resultEmail = UpcomingInterviewEmail_Schedule.generateEmail(testUser.Id, eventsUpcomingList);
        Test.stopTest();

        Assert.areEqual(
            NUMBER_OF_TEST_INTERVIEWS_UPCOMING + HEADER_ROW, 
            resultEmail.getHtmlBody().countMatches('<tr>'), 
            'The number of interview rows in the email should match the number of interviews tomorrow + 1 for header row.'
        );
        Assert.isTrue(resultEmail.toaddresses.contains(testUser.Id), 'Email is missing user in To: field');
        Assert.isTrue(resultEmail.getSubject().contains('Interview Events Upcoming'), 'Expect email subject to contain text: "Interview Events Upcoming"');
    }
    @isTest
    private static void generateEventTable_Test() {
        User user = [SELECT Id FROM User WHERE LastName LIKE '%testUser%' LIMIT 1];
        List<Event> testEvents = [SELECT Id, StartDateTime, EndDateTime, OwnerId, Subject, Location FROM Event];
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
    static void generateMapOfOwnerIdsToInterviews_Test() {
        User testUser = [SELECT Id FROM User WHERE LastName LIKE '%testUser%' LIMIT 1];
        List<Event> events = [SELECT Id, OwnerId FROM Event];

        Test.startTest();
        Map<Id, List<Event>> resultsMap = UpcomingInterviewEmail_Schedule.generateMapOfOwnerIdsToInterviews(events);
        Test.stopTest();

        Assert.areEqual(NUMBER_OF_TEST_INTERVIEWS_UPCOMING, resultsMap.get((Id)testUser.Id).size(), 'expected events to be associated with the user that matched test constant');
    }

    @TestSetup
    static void makeData(){
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1]; 
        String uniqueString = String.valueOf(DateTime.now().getTime());
        User testUser = new User(
            Alias = 'testUser',
            Username = 'testUser' + uniqueString + '@test.com',
            Email = EMAIL_TARGET_FOR_TEST,
            LastName = 'testUser' + uniqueString,
            ProfileId = standardUserProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8'
        );
        insert testUser;

        List<Event> events = new List<Event>();
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
        insert events;
    }
    @isTest
    private static void testSendDailyInterviewEmailReminders() {

        Test.startTest();
        UpcomingInterviewEmail_Schedule.sendDailyInterviewEmailReminders(LOOK_AHEAD_NEXT_N_DAYS);
        Test.stopTest();

        List<EmailMessage> sentEmails = [SELECT Subject, ToAddress, HtmlBody FROM EmailMessage WITH USER_MODE];
        System.assertEquals(1, sentEmails.size(), 'Expected 1 email to be sent');
        System.assertEquals('Interview Events Upcoming', sentEmails[0].Subject, 'Email subject is incorrect');
    }
}
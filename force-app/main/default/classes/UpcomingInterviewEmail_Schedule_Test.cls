/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class UpcomingInterviewEmail_Schedule_Test {
    private static final Integer NUMBER_OF_TEST_INTERVIEWS_TOMORROW = 5;
    private static final Id INTERVIEW_EVENT_RECORDTYPE_ID = [
        SELECT Id, Name 
        FROM RecordType 
        WHERE SobjectType = 'Event' AND Name = 'Interview' 
        LIMIT 1
    ].Id;
    private static final Integer HEADER_ROW = 1;

    @isTest
    static void upcomingInterviewEmailTest() {
        User testUser = [SELECT Id FROM User WHERE LastName LIKE '%testUser%' LIMIT 1];
        List<Event> eventsTomorrowList = [
            SELECT Id, OwnerId, Subject, StartDateTime, EndDateTime, Location, RecordTypeId
            FROM Event
            WHERE RecordTypeId = :INTERVIEW_EVENT_RECORDTYPE_ID
            AND StartDateTime = NEXT_N_DAYS:1
        ];

        Test.startTest();
        Messaging.SingleEmailMessage resultEmail = UpcomingInterviewEmail_Schedule.generateEmail(testUser.Id, eventsTomorrowList);
        Test.stopTest();

        // emails are generated as expected
        Assert.areEqual(
            NUMBER_OF_TEST_INTERVIEWS_TOMORROW + HEADER_ROW, 
            resultEmail.getHtmlBody().countMatches('<tr>'), 
            'The number of interview rows in the email should match the number of interviews tomorrow.'
        );
        Assert.isTrue(resultEmail.toaddresses.contains(testUser.Id), 'Email is missing user in To: field');
        Assert.isTrue(resultEmail.getSubject().contains('Interview Events Tomorrow:'));
    }
    @isTest
    private static void testGenerateEventTable() {
        User user = [SELECT Id FROM User WHERE LastName LIKE '%testUser%' LIMIT 1];
        List<Event> testEvents = [SELECT Id, StartDateTime, EndDateTime, OwnerId, Subject, Location FROM Event];
        Map<Id, List<Event>> ownerIdToEventsMap = new Map<Id, List<Event>>();
        
        Test.startTest();
        String eventTable = UpcomingInterviewEmail_Schedule.generateEventTable(testEvents);
        Test.stopTest();

        Assert.IsTrue(eventTable.contains('<td>Online</td><td>Test Interview 1</td>'), 'Expected HTML table to output');
    }

    @isTest 
    static void generateMapOfOwnerIdsToInterviews_Test_shouldPass() {
        User testUser = [SELECT Id FROM User WHERE LastName LIKE '%testUser%' LIMIT 1];
        List<Event> events = [SELECT Id, OwnerId FROM Event];

        Test.startTest();
        Map<Id, List<Event>> resultsMap = UpcomingInterviewEmail_Schedule.generateMapOfOwnerIdsToInterviews(events);
        Test.stopTest();

        Assert.areEqual(NUMBER_OF_TEST_INTERVIEWS_TOMORROW, resultsMap.get((Id)testUser.Id).size(), 'expected events to be associated with the user that matched test constant');
    }

    @TestSetup
    static void makeData(){
        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        String uniqueString = String.valueOf(DateTime.now().getTime());
        User testUser = new User(
            Alias = 'testUser',
            Username = 'testUser' + uniqueString + '@test.com',
            Email = 'testUser' + uniqueString + '@test.com',
            LastName = 'testUser' + uniqueString,
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8'
        );
        insert testUser;

        RecordType interviewEventRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType='Event' AND Name='Interview'];

        List<Event> events = new List<Event>();
        for (Integer i = 0; i < NUMBER_OF_TEST_INTERVIEWS_TOMORROW; i++) {
            Event newEvent = new Event(
                Subject = 'Test Interview ' + i,
                StartDateTime = DateTime.now().addDays(1),
                EndDateTime = Datetime.now().addDays(1).addMinutes(30),
                Location = 'Online',
                OwnerId = testUser.Id,
                RecordTypeId = INTERVIEW_EVENT_RECORDTYPE_ID
            );
            events.add(newEvent);
        }
        insert events;
    }
}
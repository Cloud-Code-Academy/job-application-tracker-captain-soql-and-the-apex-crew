public with sharing class EventTriggerHandler {
    public static void preventOverlappingEvents(List<Event> triggerDotNew) {
        //Map<Long, Long> newStartEndTimesInEpoch = new Map<Long, Long>();
        //Epoc Time is in https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_datetime.htm#apex_System_Datetime_getTime
        //Get time from a DateTime.
        //Article on coverting DateTime to Epoch and back
        //https://salesforce.stackexchange.com/questions/27020/converting-from-datetime-to-epoch-and-back
        Map<Id, List<Event>> ownerAssignedIdToEvents = createAssignedIdToEventListMap(triggerDotNew);
    //Possible Easy solution from StackExchange
    //https://stackoverflow.com/questions/17106670/how-to-check-a-timeperiod-is-overlapping-another-time-period-in-java
        for(Event ev: triggerDotNew){
            DatesToCompare dates = new DatesToCompare();
            dates.startDateTimeOne = ev.StartDateTime;
            dates.endDateTimeOne = ev.EndDateTime;
            for(Event eve: ownerAssignedIdToEvents.get(ev.OwnerId)){
                dates.startDateTimeTwo = eve.StartDateTime;
                dates.endDateTimeTwo = eve.EndDateTime;
                // DatesToCompare dates = new DatesToCompare(
                //     startDateOne = ev.StartDateTime,
                //     endDateOne = ev.EndDateTime,
                //     startDateTwo = eve.StartDateTime,
                //     endDateTwo = eve.EndDateTime
                // );
                if(isOverlapping(dates)){
                    ev.addError('You have another scheduled event at this time.');
                }
            }
        }
    }
    private static Boolean isOverlapping(DatesToCompare dates){
        return dates.startDateTimeOne <= dates.endDateTimeTwo && dates.startDateTimeTwo <= dates.endDateTimeOne;
    }
    private static Map<Id, List<Event>> createAssignedIdToEventListMap(List<Event> eventsToMap){
        Map<Id, List<Event>> assignedIdToEvents = new Map<Id, List<Event>>();
        for(Event ev: eventsToMap){
            assignedIdToEvents.put(ev.OwnerId, new List<Event>());
        }
        Datetime now = datetime.now();
        List<Event> eventsOwnedByUsers = [
            SELECT OwnerId, StartDateTime, EndDateTime 
            FROM Event 
            WHERE OwnerId IN :assignedIdToEvents.keySet()
            AND StartDateTime >= :now
            WITH USER_MODE
        ];
        for(Event ev: eventsOwnedByUsers){
            List<Event> eventList = assignedIdToEvents.get(ev.OwnerId);
            eventList.add(ev);
            assignedIdToEvents.put(ev.OwnerId, eventList);
        }
        return assignedIdToEvents;
    }
    private class DatesToCompare{
        private Datetime startDateTimeOne;
        private Datetime endDateTimeOne;
        private Datetime startDateTimeTwo;
        private DateTime endDateTimeTwo;

        // private DatesToCompare(Datetime startDateOne, Datetime endDateOne, Datetime startDateTwo, Datetime endDateTwo){
        //     startDateTimeOne = startDateOne;
        //     endDateTimeOne = endDateOne;
        //     startDateTimeTwo = startDateTwo;
        //     endDateTimeTwo = endDateTwo;
        // }
    }
}
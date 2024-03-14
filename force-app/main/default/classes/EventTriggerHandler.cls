public with sharing class EventTriggerHandler {
    public static void preventOverlappingEvents(List<Event> triggerDotNew) {
        //Map<Long, Long> newStartEndTimesInEpoch = new Map<Long, Long>();
        //Epoc Time is in https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_datetime.htm#apex_System_Datetime_getTime
        //Get time from a DateTime.
        //Article on coverting DateTime to Epoch and back
        //https://salesforce.stackexchange.com/questions/27020/converting-from-datetime-to-epoch-and-back
        Map<Id, List<Event>> userIdToEvents = new Map<Id, List<Event>>();
        for(Event ev: triggerDotNew){
            userIdToEvents.put(ev.OwnerId, new List<Event>());
        }
        Datetime now = datetime.now();
        List<Event> eventsOwnedByUsers = [
            SELECT OwnerId, StartDateTime, EndDateTime 
            FROM Event 
            WHERE OwnerId IN :userIdToEvents.keySet()
            AND StartDateTime >= :now
            WITH USER_MODE
        ];
        System.debug('EventsOwnedByUsers =' +  eventsOwnedByUsers);
        for(Event ev: eventsOwnedByUsers){
            List<Event> eventList = userIdToEvents.get(ev.OwnerId);
            eventList.add(ev);
            userIdToEvents.put(ev.OwnerId, eventList);
        }
        System.debug('userIdToEvents =' + userIdToEvents.values());
        for(Event ev: triggerDotNew){
            //Need to check the User with ev.OwnerId in query and sort by all of events owned by that person
            List<Event> eventList = userIdToEvents.get(ev.OwnerId);
            Long epochStartTime = ev.StartDateTime.getTime();
            Long epochEndTime = ev.EndDateTime.getTime();
            //Long epochDifference = epochEndTime - epochStartTime;
            for(Event eve: eventList){
                Long eveEpochStartTime = eve.StartDateTime.getTime();
                Long eveEpochEndTime = eve.EndDateTime.getTime();
            }
        //Possible Easy solution from StackExchange
        //https://stackoverflow.com/questions/17106670/how-to-check-a-timeperiod-is-overlapping-another-time-period-in-java

        /*
        
        Long epochStartTime = ev.StartDateTime.getTime();
        Long epochEndTime = ev.EndDateTime.getTime();
        System.debug('Epoc Start Time = '+ epochStartTime);
        System.debug('Epic End Time = ' + epochEndTime);
        */
        }
    //Possible Easy solution from StackExchange
    //https://stackoverflow.com/questions/17106670/how-to-check-a-timeperiod-is-overlapping-another-time-period-in-java
        for(Event ev: triggerDotNew){
            for(Event eve: userIdToEvents.get(ev.OwnerId)){
                if(isOverlapping(ev.StartDateTime, ev.EndDateTime, eve.StartDateTime, eve.EndDateTime)){
                    ev.addError('Not on my watch!');
                }
            }
        }
    }
    private static Boolean isOverlapping(Datetime startOne, Datetime endOne, Datetime startTwo, Datetime endTwo){
        return startOne <= endTwo && startTwo <= endOne;
    }
}
public with sharing class EventTriggerHandler {
    public static void preventOverlappingEvents(List<Event> triggerDotNew) {
        //Map<Long, Long> newStartEndTimesInEpoch = new Map<Long, Long>();
        //Epoc Time is in https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_datetime.htm#apex_System_Datetime_getTime
        //Get time from a DateTime.
        //Article on coverting DateTime to Epoch and back
        //https://salesforce.stackexchange.com/questions/27020/converting-from-datetime-to-epoch-and-back
        Map<Id, List<Event>> newUserIdToEvents = new Map<Id, List<Event>>();
        for(Event ev: triggerDotNew){
            newUserIdToEvents.put(ev.OwnerId, new List<Event>());
        }
        for(Event ev: triggerDotNew){
            //Need to check the User with ev.OwnerId in query and sort by all of events owned by that person
            List<Event> eventList = newUserIdToEvents.get(ev.OwnerId);
            eventList.add(ev);
            newUserIdToEvents.put(ev.OwnerId, eventList);
        }
        Datetime now = datetime.now();
        List<Event> eventsOwnedByUsers = [
            SELECT OwnerId, StartDateTime, EndDateTime 
            FROM Event 
            WHERE OwnerId IN :newUserIdToEvents.keySet()
            AND StartDateTime >= :now
            WITH USER_MODE
        ];
        System.debug('EventsOwnedByUsers =' +  eventsOwnedByUsers);
        for(Event ev: eventsOwnedByUsers){
            List<Event> eventList = newUserIdToEvents.get(ev.OwnerId);
            eventList.add(ev);
            newUserIdToEvents.put(ev.OwnerId, eventList);
        }
        System.debug('newUserIdToEvents =' + newUserIdToEvents.values());
        /*
        Long epochStartTime = ev.StartDateTime.getTime();
        Long epochEndTime = ev.EndDateTime.getTime();
        System.debug('Epoc Start Time = '+ epochStartTime);
        System.debug('Epic End Time = ' + epochEndTime);
        */
    }
}
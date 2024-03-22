public with sharing class JoobleIntegration_Schedule implements Schedulable{
    String key; 
    String loc;

    public void execute(SchedulableContext sc) {
        JoobleIntegration.makeHTTPCallout(key, loc);
    }
    public JoobleIntegration_Schedule(String keyword, String location){
        key = keyword;
        loc = location;
    }
}
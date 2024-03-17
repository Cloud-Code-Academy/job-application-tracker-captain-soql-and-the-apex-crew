/**
 * @description       : 
 * @author            : @Fritz
 * @group             : Cohort2
 * @last modified on  : 03-16-2024
 * @last modified by  : @Fritz
**/
public with sharing class JoobleIntegration_Mock {

    public HTTPResponse respond(HTTPRequest req) {
		// Create a fake response
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');

		// Check if the request is a POST request
		if (req.getMethod() == 'POST') {
			// Return a success response for the POST request
			res.setBody(
                '{"title": "Salesforce Developer","location": "Denver, CO","snippet": "&nbsp;...Assist CDE in reviewing UIP and related custom objects within the <b>Salesforce </b>instance in order to determine opportunities for modification,...&nbsp;&nbsp;...user) can interpret in order to support the work at the end of the contract once a <b>developer </b>is no longer available to CDE....&nbsp;","salary": "","source": "ziprecruiter.com","type": "","link": "https://jooble.org/desc/7826091234674837853?ckey=Salesforce+developer&rgn=321&pos=3&groupId=40906&elckey=5384282981589548451&p=1&aq=7121909276362868475&cid=3344&jobAge=377&relb=115&brelb=115&bscr=8519.4795&scr=8519.4795","company": "Apex Informatics","updated": "2024-03-01T00:00:00.0000000","id": 7826091234674837853}');
		} else {
			// Return the dummy user details for the GET request
			res.setBody(
                '{"title": "Salesforce Developer","location": "Denver, CO","snippet": "&nbsp;...Assist CDE in reviewing UIP and related custom objects within the <b>Salesforce </b>instance in order to determine opportunities for modification,...&nbsp;&nbsp;...user) can interpret in order to support the work at the end of the contract once a <b>developer </b>is no longer available to CDE....&nbsp;","salary": "","source": "ziprecruiter.com","type": "","link": "https://jooble.org/desc/7826091234674837853?ckey=Salesforce+developer&rgn=321&pos=3&groupId=40906&elckey=5384282981589548451&p=1&aq=7121909276362868475&cid=3344&jobAge=377&relb=115&brelb=115&bscr=8519.4795&scr=8519.4795","company": "Apex Informatics","updated": "2024-03-01T00:00:00.0000000","id": 7826091234674837853}');
		}
		res.setStatusCode(200);
		System.debug(res);
		return res;
		
	}
}

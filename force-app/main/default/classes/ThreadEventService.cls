public with sharing class ThreadEventService {

    public static Id createAsOpenAi(Thread_Event__c te) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Salesforce/services/data/v59.0/sobjects/Thread_Event__c');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        String body = JSON.serialize(te);
        System.debug('Sending:' + body);
        req.setBody(body);
        Http http = new Http();

        try {
            HttpResponse res = http.send(req);
            if (res.getStatus() == 'Created') {
                CreateResponse resBody = (CreateResponse) JSON.deserialize(res.getBody(), CreateResponse.class);
                return resBody.id;
            } else {
                System.debug('Error: ' + res.getStatusCode() + ' ' + res.getBody());
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e.getMessage());
        }
        return null;
    }

    class CreateResponse {
        public String id;
        public Boolean success;
    }
}
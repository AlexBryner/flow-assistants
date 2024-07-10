public with sharing class OpenAi {

    static final String BASE_URL = 'https://api.openai.com';
    static final String AUTH_TOKEN = OpenAI_Settings__c.getOrgDefaults().ApiKey__c;

    public OpenAiModel[] getModels() {
        return OpenAiModel.parse(
                getRequest('/v1/models')
        );
    }

    public OpenAiThread createThread() {
        return OpenAiThread.parse(
                postRequest('/v1/threads', null)
        );
    }

    public OpenAiThreadRun setAssistant(String threadId, String assistantId) {
        return OpenAiThreadRun.parse(
                postRequest('/v1/threads/' + threadId + '/runs', '{"assistant_id":"' + assistantId + '"}')
        );
    }

    public OpenAiThreadMessage postMessage(String threadId, String message) {
        return postMessage(threadId, message, null);
    }

    public OpenAiThreadMessage postMessage(String threadId, String message, List<String> fileIds) {
        OpenAiThreadMessage.PostBody body = new OpenAiThreadMessage.PostBody();
        body.role = 'user';
        body.content = message;
        if (fileIds != null) {
            body.file_ids = fileIds;
        }

        return OpenAiThreadMessage.parse(
                postRequest('/v1/threads/' + threadId + '/messages', JSON.serialize(body))
        );
    }

    public String checkRunStatus(String threadId, String runId) {
        return getRequest('/v1/threads/' + threadId + '/runs/' + runId);
    }

    public String getMessages(String threadId) {
        return getRequest('/v1/threads/' + threadId + '/messages');
    }

    static String postRequest(String urlPath, String jsonBody) {
        HttpRequest req = newRequest('POST', urlPath);
        if (jsonBody != null) {
            setRequestBody(req, jsonBody);
        }
        System.debug('Post Request: ' + req);
        System.debug('Request Body: ' + jsonBody);
        HttpResponse res = sendRequest(req);
        String body = res.getBody();
        System.debug('Post Response: ' + res);
        System.debug('Response Body: ' + body);
        return cleanJson(body);
    }

    static void setRequestBody(HttpRequest req, String jsonBody) {
        req.setBody(jsonBody);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Content-Length', String.valueOf(jsonBody.length()));
    }

    static String getRequest(String urlPath) {
        HttpRequest req = newRequest('GET', urlPath);
        System.debug('Get Request: ' + req);
        HttpResponse res = sendRequest(req);
        String body = res.getBody();
        System.debug('Get Response: ' + res);
        return cleanJson(body);
    }

    static HttpRequest newRequest(String method, String urlPath) {
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint(BASE_URL + urlPath);
        return req;
    }

    static HttpResponse sendRequest(HttpRequest req) {
        req.setHeader('Authorization', 'Bearer ' + AUTH_TOKEN);
        req.setHeader('OpenAI-Beta', 'assistants=v1');
        req.setTimeout(30000);
        return new Http().send(req);
    }

    // some of the responses seem to include trailing commas which are not handled well by JSONParser
    static String cleanJson(String jsonStr) {
        return jsonStr
                .replaceAll('\\,(\\s*[\\]])', ']')
                .replaceAll('\\,(\\s*[}])', '}');
    }
}
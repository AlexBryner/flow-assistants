public with sharing class OpenAiThread {
    
    public String id;
    public String threadType;
    public Long createdAt;
    public Map<String, Object> metadata;
    
    public OpenAiThread(String jsonStr) {
        this(JSON.createParser(jsonStr));
    }

    public OpenAiThread(JSONParser parser) {
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String fieldName = parser.getText();
                parser.nextToken();
                if (parser.getCurrentToken() == JSONToken.VALUE_NULL) {
                    continue;
                }

                if (fieldName == 'id') {
                    this.id = parser.getText();
                } else if (fieldName == 'object') {
                    this.threadType = parser.getText();
                } else if (fieldName == 'created_at') {
                    this.createdAt = parser.getLongValue();
                } else if (fieldName == 'metadata') {
                    // TODO: need to determine metadata object structure
                }
            }
        }
    }

    public static OpenAiThread parse(String responseBody) {
        return new OpenAiThread(responseBody);
    }
}
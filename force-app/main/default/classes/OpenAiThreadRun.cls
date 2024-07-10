public with sharing class OpenAiThreadRun {
    public String id;
    public String objectType;
    public Long created_at;
    public String assistant_id;
    public String thread_id;
    public String status;
    public Long started_at;
    public Long expires_at;
    public Long cancelled_at;
    public Long failed_at;
    public Long completed_at;
    public Object last_error;
    public String model;
    public String instructions;
    public List<Tool> tools;
    public List<String> file_ids;
    public Map<String, Object> metadata;
    public Object usage;

    public class Tool {
        public String type;
        public FunctionCall functionCall;

        public Tool(JSONParser parser) {

        }
    }

    public class FunctionCall {
        public String name;
        public String description;
        public Parameters parameters;

        public FunctionCall(JSONParser parser) {

        }
    }

    public class Parameters {
        public String type;
        public Map<String, Object> properties;
        public List<String> required;

        public Parameters(JSONParser parser) {

        }
    }

    public OpenAiThreadRun(String jsonString) {
        JSONParser parser = JSON.createParser(jsonString);

        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String fieldName = parser.getText();
                parser.nextToken();

                System.debug('Field Name:' + fieldName);
                
                if (parser.getCurrentToken() == JSONToken.VALUE_NULL) {
                    continue;
                }

                if (fieldName == 'id') {
                    this.id = parser.getText();
                } else if (fieldName == 'object') {
                    this.objectType = parser.getText();
                } else if (fieldName == 'created_at') {
                    this.created_at = parser.getLongValue();
                } else if (fieldName == 'assistant_id') {
                    this.assistant_id = parser.getText();
                } else if (fieldName == 'thread_id') {
                    this.thread_id = parser.getText();
                } else if (fieldName == 'status') {
                    this.status = parser.getText();
                } else if (fieldName == 'started_at') {
                    this.started_at = parser.getLongValue();
                } else if (fieldName == 'expires_at') {
                    this.expires_at = parser.getLongValue();
                } else if (fieldName == 'cancelled_at') {
                    this.cancelled_at = parser.getLongValue();
                } else if (fieldName == 'failed_at') {
                    this.failed_at = parser.getLongValue();
                } else if (fieldName == 'failed_at') {
                    this.failed_at = parser.getLongValue();
                } else if (fieldName == 'model') {
                    this.model = parser.getText();
                } else if (fieldName == 'instructions') {
                    this.instructions = parser.getText();
                } else if (fieldName == 'tools' && parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    this.tools = new List<Tool>();
                    while (parser.nextToken() != JSONToken.END_ARRAY) {
                        this.tools.add(new Tool(parser));
                    }
                } else if (fieldName == 'file_ids' && parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    this.file_ids = new List<String>();
                    while (parser.nextToken() != JSONToken.END_ARRAY) {
                        this.file_ids.add(parser.getText());
                    }
                } else if (fieldName == 'metadata') {

                }
            }
        }
    }

    public static OpenAiThreadRun parse(String jsonStr) {
        return new OpenAiThreadRun(jsonStr);
    }
}
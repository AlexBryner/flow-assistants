public with sharing class OpenAiThreadMessage {
    public String id;
    public String objectType; // Adjusted for the 'object' JSON key
    public Long created_at;
    public String assistant_id;
    public String thread_id;
    public String run_id;
    public String role;
    public List<ContentItem> content;
    public List<String> file_ids;
    public Map<String, Object> metadata;

    public class PostBody {
        public String role;
        public String content;
        public String[] file_ids = new List<String>();
    }

    // Nested classes for content
    public class ContentItem {
        public String type;
        public TextItem text;

        public ContentItem(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                String contentField = parser.getText();
                parser.nextToken();
            }
        }
    }

    public class TextItem {
        public String value;
        public List<Object> annotations;

        public TextItem(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                String nextFieldName = parser.getText();
                parser.nextToken();
                if (nextFieldName == 'value') {
                    this.value = parser.getText();
                } else if (nextFieldName == 'annotations') {

                }
            }
        }
    }

    public OpenAiThreadMessage(String jsonString) {
        JSONParser parser = JSON.createParser(jsonString);
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String fieldName = parser.getText();
                parser.nextToken();
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
                } else if (fieldName == 'run_id') {
                    this.run_id = parser.getText();
                } else if (fieldName == 'role') {
                    this.role = parser.getText();
                } else if (fieldName == 'content' && parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    this.content = new List<ContentItem>();
                    while (parser.nextToken() != JSONToken.END_ARRAY) {
                        content.add(new ContentItem(parser));
                    }
                } else if (fieldName == 'file_ids' && parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    this.file_ids = new List<String>();
                    while (parser.nextToken() != JSONToken.END_ARRAY) {
                        this.file_ids.add(parser.getText());
                    }
                } else if (fieldName == 'metadata') {
                    // TODO
                }
            }
        }
    }

    public static OpenAiThreadMessage parse(String jsonString) {
        return new OpenAiThreadMessage(jsonString);
    }
}
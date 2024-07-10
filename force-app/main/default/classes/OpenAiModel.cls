public with sharing class OpenAiModel {

    // The model identifier, which can be referenced in the API endpoints.
    public String id;
    // The Unix timestamp (in seconds) when the model was created.
    public Long created;
    // The object type, which is always "model".
    public String objectType;
    // The organization that owns the model.
    public String ownedBy;

    public OpenAiModel(JSONParser parser) {
        while (parser.nextToken() != JSONToken.END_OBJECT) {
            String fieldName = parser.getText();
            parser.nextToken();
            if (parser.getCurrentToken() == JSONToken.VALUE_NULL) {
                continue;
            }
            if (fieldName == 'id') {
                this.id = parser.getText();
            } else if (fieldName == 'created') {
                this.created = parser.getLongValue();
            } else if (fieldName == 'object') {
                this.objectType = parser.getText();
            } else if (fieldName == 'owned_by') {
                this.ownedBy = parser.getText();
            }
            System.debug('Current Token 2: ' + parser.getCurrentToken());
        }
    }

    public static OpenAiModel[] parse(String jsonStr) {
        OpenAiModel[] models = new List<OpenAiModel>();
        JSONParser parser = JSON.createParser(jsonStr);
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                if (parser.getCurrentToken() == JSONToken.VALUE_NULL) {
                    continue;
                }

                if (parser.getText() == 'data') {
                    parser.nextToken();
                    while (parser.nextToken() != JSONToken.END_ARRAY) {
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                            models.add(new OpenAiModel(parser));
                        }
                    }
                }
            }
        }
        return models;
    }
}
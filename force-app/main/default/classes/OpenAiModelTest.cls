@IsTest
private class OpenAiModelTest {

    @IsTest
    static void shouldParseModelList() {
        String modelsString = '{' +
        '  "object": "list",' +
        '  "data": [' +
        '    {' +
        '      "id": "model-id-0",' +
        '      "object": "model",' +
        '      "created": 1686935002,' +
        '      "owned_by": "organization-owner"' +
        '    },' +
        '    {' +
        '      "id": "model-id-1",' +
        '      "object": "model",' +
        '      "created": 1686935002,' +
        '      "owned_by": "organization-owner"' +
        '    },' +
        '    {' +
        '      "id": "model-id-2",' +
        '      "object": "model",' +
        '      "created": 1686935002,' +
        '      "owned_by": "openai"' +
        '    }' +
        '  ]' +
        '}';

        Test.startTest();
        OpenAiModel[] models = OpenAiModel.parse(modelsString);
        Test.stopTest();

        System.assertEquals(3, models.size(), 'Expected To Parse Response Into 3 Models');
    }
}
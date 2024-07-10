@IsTest
private class OpenAiThreadTest {

    @IsTest
    static void shouldParseThread() {
        String threadJson = '' +
                '{\n' +
                '  "id": "thread_with_unique_id",\n' +
                '  "object": "thread",\n' +
                '  "created_at": 1708309987,\n' +
                '  "metadata": {},\n' +
                '  "tool_resources": []\n' +
                '}';

        Test.startTest();
        OpenAiThread thread = new OpenAiThread(threadJson);
        Test.stopTest();

        System.assertEquals('thread_with_unique_id', thread.id, 'Expected To Parse Thread Id');
    }
}
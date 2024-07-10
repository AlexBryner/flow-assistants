@IsTest
public with sharing class OpenAiThreadRunTest {

    @IsTest
    public static void shouldParseThreadRun() {
        String jsonStr = '{' +
                '  "id": "run_id",' +
                '  "object": "thread.run",' +
                '  "created_at": 1708309988,' +
                '  "assistant_id": "asst_id",' +
                '  "thread_id": "thread_id",' +
                '  "status": "in_progress",' +
                '  "started_at": 1708309988,' +
                '  "expires_at": 1708310588,' +
                '  "cancelled_at": null,' +
                '  "failed_at": null,' +
                '  "completed_at": null,' +
                '  "last_error": null,' +
                '  "model": "gpt-4-turbo-preview",' +
                '  "instructions": "some great instructions",' +
                '  "tools": [' +
                '    {' +
                '      "type": "function",' +
                '      "function": {' +
                '        "name": "outage_report",' +
                '        "description": "Capture details from a user reporting a negative experience or disruption of service",' +
                '        "parameters": {' +
                '          "type": "object",' +
                '          "properties": {' +
                '            "report_type": {' +
                '              "type": "string",' +
                '              "enum": [' +
                '                "outage",' +
                '                "bug"' +
                '              ]' +
                '            },' +
                '            "severity_level": {' +
                '              "type": "string"' +
                '            },' +
                '            "impact": {' +
                '              "type": "string"' +
                '            },' +
                '            "time_sensitivity": {' +
                '              "type": "string"' +
                '            },' +
                '            "is_workaround_available": {' +
                '              "type": "boolean"' +
                '            },' +
                '            "description": {' +
                '              "type": "string"' +
                '            },' +
                '            "details": {' +
                '              "type": "string"' +
                '            }' +
                '          },' +
                '          "required": [' +
                '            "severity_level",' +
                '            "impact",' +
                '            "time_sensitivity"' +
                '          ]' +
                '        }' +
                '      }' +
                '    }' +
                '  ],' +
                '  "file_ids": [],' +
                '  "metadata": {},' +
                '  "usage": null' +
                '}';

        Test.startTest();
        OpenAiThreadRun threadRun = OpenAiThreadRun.parse(jsonStr);
        Test.stopTest();


    }
}
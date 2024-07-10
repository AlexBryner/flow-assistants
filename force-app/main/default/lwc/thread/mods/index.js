const setDisplayMetaOnThreadEvents = (threadEvents) => {
    return threadEvents.map((e, i) => {
        if (i + 1 === threadEvents.length || threadEvents[i].actor.id !== threadEvents[i + 1].actor.id) {
            return {...e, displayMeta: true}
        }
        return { ...e, displayMeta: false };
    });
}

const extractParametersFromFunction = (responseBody = '') => {
    const parsedResponse = JSON.parse(responseBody);
    const toolCall = parsedResponse.required_action.submit_tool_outputs.tool_calls.find(tc => !!tc.function.name);
    const functionCallArguments = JSON.parse(toolCall['function']['arguments']);
    const functionProperties = parsedResponse.tools.find(t => t.type === 'function' && t.function.name === toolCall.function.name)?.function.parameters.properties;

    if (toolCall) {
        return {
            type: 'flow',
            flowName: toolCall.function.name,
            inputVariables: Object.keys(functionProperties).map(p => {
                return {name: p, type: functionProperties[p].type, value: functionCallArguments[p]}
            })
        }
    }
}

export { setDisplayMetaOnThreadEvents, extractParametersFromFunction }
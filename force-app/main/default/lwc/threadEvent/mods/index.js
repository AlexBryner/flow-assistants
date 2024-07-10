const markdownToHtml = (markdownInput = '') => {
    let html = markdownInput
        // Replace ### Header with <h3>Header</h3>
        .replace(/^(######\s)(.*)$/gm, '<h6>$2</h6>')
        .replace(/^(#####\s)(.*)$/gm, '<h5>$2</h5>')
        .replace(/^(####\s)(.*)$/gm, '<h4>$2</h4>')
        .replace(/^(###\s)(.*)$/gm, '<h3>$2</h3>')
        .replace(/^(##\s)(.*)$/gm, '<h2>$2</h2>')
        // Replace **bold** or __bold__ with <b>bold</b>
        .replace(/\*\*(.*?)\*\*/g, '<b>$1</b>')
        .replace(/__(.*?)__/g, '<b>$1</b>')
        // Replace *italic* or _italic_ with <i>italic</i>
        .replace(/\*(.*?)\*/g, '<i>$1</i>')
        .replace(/_(.*?)_/g, '<i>$1</i>')
        // Replace escaped newlines with <br/>
        .replace(/\\n/g, '<br/>')
        // Triple dashes to em dash
        .replace(/---/g, '&mdash;');

    // Replace ordered lists
    html = html.split('\n').map((line, index, lines) => {
        if (line.match(/^\d+\./)) {
            if (index === 0 || !lines[index - 1].match(/^\d+\./)) {
                line = '<ol><li>' + line.replace(/^\d+\.\s*/, '');
            } else {
                line = '<li>' + line.replace(/^\d+\.\s*/, '');
            }
            if (index === lines.length - 1 || !lines[index + 1].match(/^\d+\./)) {
                line += '</li></ol>';
            } else {
                line += '</li>';
            }
        }
        return line;
    }).join('\n').replace(/\n/g, '');

    // Replace unordered lists
    html = html.split('\n').map((line, index, lines) => {
        if (line.match(/^\* /) || line.match(/^- /)) {
            if (index === 0 || (!lines[index - 1].match(/^\* /) && !lines[index - 1].match(/^- /))) {
                line = '<ul><li>' + line.replace(/^(\* |-)\s*/, '');
            } else {
                line = '<li>' + line.replace(/^(\* |-)\s*/, '');
            }
            if (index === lines.length - 1 || (!lines[index + 1].match(/^\* /) && !lines[index + 1].match(/^- /))) {
                line += '</li></ul>';
            } else {
                line += '</li>';
            }
        }
        return line;
    }).join('\n').replace(/\n/g, '');

    return html;
}

export { markdownToHtml }
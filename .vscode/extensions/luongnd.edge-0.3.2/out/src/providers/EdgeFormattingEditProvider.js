"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const html = require("vscode-html-languageservice");
const lst = require("vscode-languageserver-types");
const EdgeFormatter_1 = require("../services/EdgeFormatter");
const service = html.getLanguageService();
class EdgeFormattingEditProvider {
    provideDocumentFormattingEdits(document, options) {
        let range = new vscode.Range(new vscode.Position(0, 0), new vscode.Position((document.lineCount - 1), Number.MAX_VALUE));
        return this.provideFormattingEdits(document, document.validateRange(range), options);
    }
    provideDocumentRangeFormattingEdits(document, range, options) {
        return this.provideFormattingEdits(document, range, options);
    }
    provideFormattingEdits(document, range, options) {
        this.formatterOptions = {
            tabSize: options.tabSize,
            insertSpaces: options.insertSpaces
        };
        //  Mapping HTML format options
        let htmlFormatConfig = vscode.workspace.getConfiguration('html.format');
        Object.assign(options, htmlFormatConfig);
        // format as html
        let doc = lst.TextDocument.create(document.uri.fsPath, 'html', 1, document.getText());
        let htmlTextEdit = service.format(doc, range, options);
        // format as edge
        let formatter = new EdgeFormatter_1.EdgeFormatter(this.formatterOptions);
        let edgeText = formatter.format(htmlTextEdit[0].newText);
        return [vscode.TextEdit.replace(range, edgeText)];
    }
}
exports.EdgeFormattingEditProvider = EdgeFormattingEditProvider;
//# sourceMappingURL=EdgeFormattingEditProvider.js.map
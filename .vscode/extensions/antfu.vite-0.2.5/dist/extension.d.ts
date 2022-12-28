import { ExtensionContext } from 'vscode';

declare function activate(ext: ExtensionContext): Promise<void>;
declare function deactivate(): Promise<void>;

export { activate, deactivate };

import * as vscode from 'vscode';
import * as path from 'path';
import * as fs from 'fs';

export function activate(context: vscode.ExtensionContext) {
  const disposable = vscode.commands.registerCommand('extension.showTimeline', () => {
    const options: vscode.OpenDialogOptions = {
      canSelectFiles: false,
      canSelectFolders: true,
      openLabel: 'Select Session Folder'
    };
    vscode.window.showOpenDialog(options).then(folder => {
      if (folder && folder[0]) {
        const session = folder[0].fsPath;
        const dbPath = path.join(session, 'session.sqlite');
        if (fs.existsSync(dbPath)) {
          vscode.window.showInformationMessage('Session DB found: ' + dbPath);
          // Further implementation: launch webview with timeline
        } else {
          vscode.window.showErrorMessage('session.sqlite not found in selected folder');
        }
      }
    });
  });
  context.subscriptions.push(disposable);
}
export function deactivate() {}

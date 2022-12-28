"use strict";Object.defineProperty(exports, "__esModule", {value: true}); function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }// src/extension.ts
var _vscode = require('vscode');

// src/config.ts

function getConfig(key, v) {
  return _vscode.workspace.getConfiguration().get(`vite.${key}`, v);
}
var Config = {
  get root() {
    var _a, _b, _c;
    return ((_c = (_b = (_a = _vscode.workspace.workspaceFolders) == null ? void 0 : _a[0]) == null ? void 0 : _b.uri) == null ? void 0 : _c.fsPath) || "";
  },
  get autoStart() {
    return getConfig("autoStart", true);
  },
  get browser() {
    return getConfig("browserType", "embedded");
  },
  get pingInterval() {
    return getConfig("pingInterval", 200);
  },
  get maximumTimeout() {
    return getConfig("maximumTimeout", 3e4);
  },
  get showTerminal() {
    return getConfig("showTerminal", false);
  },
  get notifyOnStarted() {
    return getConfig("notifyOnStarted", true);
  },
  get port() {
    return getConfig("port", 4e3);
  },
  get host() {
    return getConfig("host", "localhost");
  },
  get https() {
    return getConfig("https", false);
  },
  get base() {
    return getConfig("base", "");
  },
  get vitepress() {
    return getConfig("vitepress", true);
  },
  get vitepressAutoRouting() {
    return getConfig("vitepressAutoRouting", false);
  },
  get vitepressBase() {
    return getConfig("vitepressBase", "");
  },
  get buildCommand() {
    return getConfig("buildCommand", "npm run build");
  },
  get devCommand() {
    return getConfig("devCommand");
  },
  get open() {
    var _a;
    return (_a = getConfig("open")) != null ? _a : true;
  }
};
function composeUrl(port) {
  return `${Config.https ? "https" : "http"}://${Config.host}:${port}${Config.base}`;
}

// src/utils.ts
var _http = require('http'); var _http2 = _interopRequireDefault(_http);
var _https = require('https'); var _https2 = _interopRequireDefault(_https);
var _path = require('path');
var _fs = require('fs'); var _fs2 = _interopRequireDefault(_fs);

// src/Context.ts
var ctx = {
  active: false,
  currentMode: "dev",
  command: "vite"
};

// src/utils.ts
function isPortFree(port) {
  return new Promise((resolve) => {
    const server = _http2.default.createServer().listen(port, () => {
      server.close();
      resolve(true);
    }).on("error", () => {
      resolve(false);
    });
  });
}
function timeout(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
async function tryPort(start2 = 4e3) {
  if (await isPortFree(start2))
    return start2;
  return tryPort(start2 + 1);
}
function ping(url) {
  const promise = new Promise((resolve) => {
    const useHttps = url.indexOf("https") === 0;
    const mod = useHttps ? _https2.default.request : _http2.default.request;
    const pingRequest = mod(url, () => {
      resolve(true);
      pingRequest.destroy();
    });
    pingRequest.on("error", () => {
      resolve(false);
      pingRequest.destroy();
    });
    pingRequest.write("");
    pingRequest.end();
  });
  return promise;
}
async function waitFor(url, interval = 200, max = 3e4) {
  let times = Math.ceil(max / interval);
  while (times > 0) {
    times -= 1;
    if (await ping(url))
      return true;
    await timeout(interval);
  }
  return false;
}
function isViteProject() {
  return _fs2.default.existsSync(_path.join.call(void 0, Config.root, "vite.config.ts")) || _fs2.default.existsSync(_path.join.call(void 0, Config.root, "vite.config.js")) || Config.vitepress && hasDependencies("vitepress");
}
function loadPackageJSON() {
  const path = _path.join.call(void 0, Config.root, "package.json");
  if (_fs2.default.existsSync(path))
    return JSON.parse(_fs2.default.readFileSync(path, "utf-8"));
}
function getName(str) {
  if (str === "vitepress")
    return "VitePress";
  return "Vite";
}
function hasDependencies(name) {
  var _a, _b, _c, _d;
  return Boolean(((_b = (_a = ctx.packageJSON) == null ? void 0 : _a.dependencies) == null ? void 0 : _b[name]) || ((_d = (_c = ctx.packageJSON) == null ? void 0 : _c.devDependencies) == null ? void 0 : _d[name]));
}
function hasNodeModules() {
  return _fs2.default.existsSync(_path.join.call(void 0, Config.root, "node_modules"));
}
function getNi() {
  if (_fs2.default.existsSync(_path.join.call(void 0, Config.root, "pnpm-lock.yaml")))
    return "pnpm install";
  else if (_fs2.default.existsSync(_path.join.call(void 0, Config.root, "yarn.lock")))
    return "yarn install";
  return "npm install";
}

// src/terminal.ts

function ensureTerminal() {
  if (isTerminalActive())
    return;
  ctx.terminal = _vscode.window.createTerminal("Vite");
}
function isTerminalActive() {
  return ctx.terminal && ctx.terminal.exitStatus == null;
}
function closeTerminal() {
  if (isTerminalActive()) {
    ctx.terminal.sendText("");
    ctx.terminal.dispose();
    ctx.terminal = void 0;
  }
}
function endProcess() {
  if (isTerminalActive())
    ctx.terminal.sendText("");
  ctx.ext.globalState.update("pid", void 0);
}
async function executeCommand(cmd) {
  ensureTerminal();
  ctx.terminal.sendText(cmd);
  if (Config.showTerminal)
    ctx.terminal.show(false);
  await timeout(2e3);
  const pid = await ctx.terminal.processId;
  if (pid)
    ctx.ext.globalState.update("pid", pid);
}

// src/recover.ts

async function tryRecoverTerminal() {
  if (ctx.terminal)
    return;
  const pid = ctx.ext.globalState.get("pid");
  if (!pid)
    return;
  const terminals = await Promise.all(_vscode.window.terminals.map(async (i) => pid === await i.processId ? i : void 0));
  const terminal = terminals.find((i) => i);
  if (terminal) {
    ctx.terminal = terminal;
    return true;
  }
}
async function tryRecoverState() {
  if (!await tryRecoverTerminal())
    return;
  const port = +(ctx.ext.globalState.get("port") || 0);
  if (!port)
    return;
  const url = composeUrl(port);
  if (!await ping(url))
    return;
  ctx.active = true;
  ctx.url = url;
  ctx.port = port;
  ctx.currentMode = ctx.ext.globalState.get("mode") || "dev";
  return true;
}

// src/statusBar.ts

function ensureStatusBar() {
  if (!ctx.statusBar) {
    ctx.statusBar = _vscode.window.createStatusBarItem(_vscode.StatusBarAlignment.Right, 1e3);
    ctx.statusBar.command = "vite.showCommands";
    ctx.statusBar.show();
  }
}
function updateStatusBar() {
  ensureStatusBar();
  if (ctx.command === "vitepress") {
    if (ctx.active) {
      ctx.statusBar.text = ctx.currentMode === "serve" ? "$(repo) VitePress (Build)" : "$(repo) VitePress";
      ctx.statusBar.color = "#42b883";
    } else {
      ctx.statusBar.text = "$(stop-circle) VitePress";
      ctx.statusBar.color = void 0;
    }
  } else {
    if (ctx.active) {
      ctx.statusBar.text = ctx.currentMode === "serve" ? "$(symbol-event) Vite (Build)" : "$(symbol-event) Vite";
      ctx.statusBar.color = "#ebb549";
    } else {
      ctx.statusBar.text = "$(stop-circle) Vite";
      ctx.statusBar.color = void 0;
    }
  }
}

// src/showCommands.ts


// src/open.ts


// src/start.ts

async function start({
  mode = "dev",
  searchPort = !ctx.active,
  waitForStart = true,
  stopPrevious = true
} = {}) {
  if (stopPrevious)
    stop();
  if (mode !== ctx.currentMode)
    closePanel();
  ctx.currentMode = mode;
  if (!ctx.port || searchPort)
    ctx.port = await tryPort(Config.port);
  ctx.url = composeUrl(ctx.port);
  ctx.ext.globalState.update("port", ctx.port);
  if (mode === "dev") {
    let command = Config.devCommand;
    if (!command) {
      command = ctx.command === "vitepress" ? Config.vitepressBase ? `npx vitepress dev ${Config.vitepressBase}` : "npx vitepress" : "npx vite";
    }
    command += ` --port=${ctx.port}`;
    executeCommand(command);
  } else {
    if (Config.buildCommand)
      executeCommand(Config.buildCommand);
    if (ctx.command === "vitepress") {
      let path = ".vitepress/dist";
      if (Config.vitepressBase)
        path = `${Config.vitepressBase}/${path}`;
      executeCommand(`npx live-server ${path} --port=${ctx.port} --no-browser`);
    } else {
      executeCommand(`npx live-server dist --port=${ctx.port} --no-browser`);
    }
  }
  if (waitForStart) {
    if (!await waitFor(ctx.url, Config.pingInterval, Config.maximumTimeout)) {
      _vscode.window.showErrorMessage("\u2757\uFE0F Failed to start the server");
      stop();
    } else {
      if (Config.notifyOnStarted) {
        _vscode.window.showInformationMessage(mode === "build" ? `\u{1F4E6} ${getName(ctx.command)} build served at ${ctx.url}` : `\u26A1\uFE0F ${getName(ctx.command)} started at ${ctx.url}`);
      }
    }
  }
  ctx.active = true;
  updateStatusBar();
}
function stop() {
  ctx.active = false;
  endProcess();
  updateStatusBar();
}

// src/open.ts
async function open({
  autoStart = false,
  browser = Config.browser,
  stopPrevious = true
} = {}) {
  var _a, _b, _c;
  if (!ctx.active && autoStart)
    await start({stopPrevious});
  if (!ctx.active || !ctx.url)
    return;
  if (browser === "system") {
    _vscode.env.openExternal(_vscode.Uri.parse(ctx.url));
  } else if (browser === "embedded") {
    if (!ctx.panel || ((_a = ctx.panel) == null ? void 0 : _a.disposed)) {
      ctx.panel = await _vscode.commands.executeCommand("browse-lite.open", ctx.url);
    }
    try {
      (_c = (_b = ctx.panel) == null ? void 0 : _b.show) == null ? void 0 : _c.call(_b);
    } catch (e3) {
    }
  }
}
function closePanel() {
  var _a, _b;
  (_b = (_a = ctx.panel) == null ? void 0 : _a.dispose) == null ? void 0 : _b.call(_a);
  ctx.panel = void 0;
}

// src/showCommands.ts
async function showCommands() {
  var _a;
  const commands3 = [
    {
      label: ctx.command === "vitepress" ? "$(repo) Start VitePress server" : "$(symbol-event) Start Vite server",
      handler() {
        start();
      },
      if: !ctx.active
    },
    {
      label: "$(split-horizontal) Open in embedded browser",
      description: ctx.url,
      handler() {
        open({autoStart: true, browser: "embedded"});
      }
    },
    {
      label: "$(link-external) Open in system browser",
      description: ctx.url,
      handler() {
        open({autoStart: true, browser: "system"});
      }
    },
    {
      label: ctx.currentMode === "dev" ? `$(refresh) Restart ${getName(ctx.command)} server` : "$(symbol-event) Switch to dev server",
      async handler() {
        const reopen = ctx.panel && ctx.active && ctx.currentMode !== "dev";
        await start({mode: "dev", searchPort: ctx.currentMode !== "dev"});
        if (reopen)
          await open({browser: "embedded"});
      },
      if: ctx.active
    },
    {
      label: ctx.active && ctx.currentMode === "serve" ? "$(package) Rebuild and Serve" : "$(package) Build and Serve",
      async handler() {
        const reopen = ctx.panel && ctx.active && ctx.currentMode !== "serve";
        await start({mode: "serve", searchPort: ctx.currentMode !== "serve"});
        if (reopen)
          await open({browser: "embedded"});
      }
    },
    {
      label: "$(terminal) Show Terminal",
      handler() {
        stop();
      },
      if: ctx.active
    },
    {
      label: "$(close) Stop server",
      handler() {
        stop();
      },
      if: ctx.active
    }
  ];
  const result = await _vscode.window.showQuickPick(commands3.filter((i) => i.if !== false));
  if (result)
    (_a = result.handler) == null ? void 0 : _a.call(result);
}

// src/vitepressAutoRouting.ts


function enableVitepressAutoRouting() {
  _vscode.window.onDidChangeActiveTextEditor((e) => {
    var _a;
    const doc = e == null ? void 0 : e.document;
    const root = Config.vitepressBase ? _path.join.call(void 0, Config.root, Config.vitepressBase) : Config.root;
    if (!(doc == null ? void 0 : doc.uri.path.endsWith(".md")))
      return;
    const path = _path.relative.call(void 0, root, doc == null ? void 0 : doc.uri.fsPath).replace(/\\/g, "/").replace(/\.md$/, "").replace(/\/index$/, "/");
    if (path.startsWith(".."))
      return;
    const url = `${composeUrl(ctx.port)}/${path}`;
    try {
      (_a = ctx.panel) == null ? void 0 : _a.navigateTo(url);
    } catch (e2) {
      console.error(e2);
    }
  });
}

// src/extension.ts
async function activate(ext) {
  ctx.ext = ext;
  _vscode.commands.registerCommand("vite.stop", stop);
  _vscode.commands.registerCommand("vite.restart", start);
  _vscode.commands.registerCommand("vite.open", () => open());
  _vscode.commands.registerCommand("vite.showCommands", showCommands);
  _vscode.window.onDidCloseTerminal((e) => {
    if (e === ctx.terminal) {
      stop();
      ctx.terminal = void 0;
    }
  });
  ctx.packageJSON = loadPackageJSON();
  if (!isViteProject())
    return;
  if (Config.vitepress && hasDependencies("vitepress")) {
    ctx.command = "vitepress";
    if (Config.vitepressAutoRouting)
      enableVitepressAutoRouting();
  }
  await tryRecoverState();
  updateStatusBar();
  if (Config.autoStart) {
    if (!hasNodeModules()) {
      const ni = getNi();
      const result = await _vscode.window.showWarningMessage("Vite: It seems like you didn't have node modules installed, would you like to install it now?", `Install (${ni})`, "Cancel");
      if (result && result !== "Cancel") {
        executeCommand(ni);
        await timeout(5e3);
      } else {
        return;
      }
    }
    if (Config.open)
      open({autoStart: true, stopPrevious: false});
  }
}
async function deactivate() {
  closeTerminal();
}



exports.activate = activate; exports.deactivate = deactivate;

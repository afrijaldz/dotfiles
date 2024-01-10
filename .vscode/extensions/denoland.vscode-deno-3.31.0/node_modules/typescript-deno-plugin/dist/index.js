var __create = Object.create;
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getProtoOf = Object.getPrototypeOf;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target, mod));
var __accessCheck = (obj, member, msg) => {
  if (!member.has(obj))
    throw TypeError("Cannot " + msg);
};
var __privateGet = (obj, member, getter) => {
  __accessCheck(obj, member, "read from private field");
  return getter ? getter.call(obj) : member.get(obj);
};
var __privateAdd = (obj, member, value) => {
  if (member.has(obj))
    throw TypeError("Cannot add the same private member more than once");
  member instanceof WeakSet ? member.add(obj) : member.set(obj, value);
};
var __privateSet = (obj, member, value, setter) => {
  __accessCheck(obj, member, "write to private field");
  setter ? setter.call(obj, value) : member.set(obj, value);
  return value;
};
var __privateMethod = (obj, member, method) => {
  __accessCheck(obj, member, "access private method");
  return method;
};

// typescript-deno-plugin/src/index.ts
var path = __toESM(require("path"));
var os = __toESM(require("os"));
var util = __toESM(require("util"));
var projectSettings = /* @__PURE__ */ new Map();
var defaultSettings = {
  cache: null,
  cacheOnSave: false,
  certificateStores: null,
  enable: null,
  disablePaths: [],
  enablePaths: [],
  codeLens: null,
  config: null,
  documentPreloadLimit: null,
  maxTsServerMemory: null,
  importMap: null,
  inlayHints: null,
  internalDebug: false,
  internalInspect: false,
  lint: false,
  logFile: false,
  path: null,
  suggest: {
    autoImports: true,
    completeFunctionCalls: false,
    names: true,
    paths: true,
    imports: {
      autoDiscover: true,
      hosts: {}
    }
  },
  testing: null,
  tlsCertificate: null,
  unsafelyIgnoreCertificateErrors: null,
  unstable: false
};
function updateSettings(project, settings) {
  projectSettings.set(project.getProjectName(), settings);
  Object.assign(defaultSettings, settings.workspace);
}
var _project, _projectName, _denoEnabled, denoEnabled_fn, _fileNameDenoEnabled, fileNameDenoEnabled_fn, _log, _loggingEnabled;
var Plugin = class {
  constructor() {
    __privateAdd(this, _denoEnabled);
    __privateAdd(this, _fileNameDenoEnabled);
    __privateAdd(this, _project, void 0);
    __privateAdd(this, _projectName, void 0);
    __privateAdd(this, _log, (..._msgs) => {
    });
    __privateAdd(this, _loggingEnabled, () => true);
  }
  create(info) {
    const { languageService: ls, project, config } = info;
    __privateSet(this, _log, (...msgs) => {
      project.projectService.logger.info(`[typescript-deno-plugin] ${msgs.map((m) => typeof m === "string" ? m : util.inspect(m)).join(" ")}`);
    });
    __privateSet(this, _loggingEnabled, () => {
      return project.projectService.logger.loggingEnabled();
    });
    __privateSet(this, _project, project);
    __privateSet(this, _projectName, project.getProjectName());
    updateSettings(__privateGet(this, _project), config);
    setImmediate(() => {
      __privateGet(this, _project).refreshDiagnostics();
    });
    const callIfDisabled = (fn, fileNameArg, emptyReturn) => {
      const target = ls[fn];
      return (...args) => {
        if (__privateGet(this, _loggingEnabled).call(this)) {
          __privateGet(this, _log).call(this, fn, args);
        }
        const enabled = fileNameArg !== void 0 ? __privateMethod(this, _fileNameDenoEnabled, fileNameDenoEnabled_fn).call(this, args[fileNameArg]) : __privateMethod(this, _denoEnabled, denoEnabled_fn).call(this);
        return enabled ? Array.isArray(emptyReturn) ? [] : typeof emptyReturn === "function" ? emptyReturn() : emptyReturn : target.call(ls, ...args);
      };
    };
    const projectGetGlobalProjectErrors = __privateGet(this, _project).getGlobalProjectErrors;
    __privateGet(this, _project).getGlobalProjectErrors = () => __privateMethod(this, _denoEnabled, denoEnabled_fn).call(this) ? [] : projectGetGlobalProjectErrors.call(__privateGet(this, _project));
    const projectGetAllProjectErrors = __privateGet(this, _project).getAllProjectErrors;
    __privateGet(this, _project).getAllProjectErrors = () => __privateMethod(this, _denoEnabled, denoEnabled_fn).call(this) ? [] : projectGetAllProjectErrors.call(__privateGet(this, _project));
    const commentSelection = callIfDisabled("commentSelection", 0, []);
    const findReferences = callIfDisabled("findReferences", 0, void 0);
    const findRenameLocations = callIfDisabled("findRenameLocations", 0, void 0);
    const getApplicableRefactors = callIfDisabled("getApplicableRefactors", 0, []);
    const getBraceMatchingAtPosition = callIfDisabled("getBraceMatchingAtPosition", 0, []);
    const getBreakpointStatementAtPosition = callIfDisabled("getBreakpointStatementAtPosition", 0, void 0);
    const getCodeFixesAtPosition = callIfDisabled("getCodeFixesAtPosition", 0, []);
    const getCompilerOptionsDiagnostics = callIfDisabled("getCompilerOptionsDiagnostics", void 0, []);
    const getCompletionEntryDetails = callIfDisabled("getCompletionEntryDetails", 0, void 0);
    const getCompletionEntrySymbol = callIfDisabled("getCompletionEntrySymbol", 0, void 0);
    const getCompletionsAtPosition = callIfDisabled("getCompletionsAtPosition", 0, void 0);
    const getDefinitionAndBoundSpan = callIfDisabled("getDefinitionAndBoundSpan", 0, void 0);
    const getDefinitionAtPosition = callIfDisabled("getDefinitionAtPosition", 0, void 0);
    const getDocCommentTemplateAtPosition = callIfDisabled("getDocCommentTemplateAtPosition", 0, void 0);
    const getDocumentHighlights = callIfDisabled("getDocumentHighlights", 0, void 0);
    const getEditsForFileRename = callIfDisabled("getEditsForFileRename", 0, []);
    const getEditsForRefactor = callIfDisabled("getEditsForRefactor", 0, void 0);
    const getEncodedSemanticClassifications = callIfDisabled("getEncodedSemanticClassifications", 0, () => ({ spans: [], endOfLineState: 0 }));
    const getEncodedSyntacticClassifications = callIfDisabled("getEncodedSyntacticClassifications", 0, () => ({ spans: [], endOfLineState: 0 }));
    const getImplementationAtPosition = callIfDisabled("getImplementationAtPosition", 0, void 0);
    const getJsxClosingTagAtPosition = callIfDisabled("getJsxClosingTagAtPosition", 0, void 0);
    const getNameOrDottedNameSpan = callIfDisabled("getNameOrDottedNameSpan", 0, void 0);
    const getNavigateToItems = callIfDisabled("getNavigateToItems", void 0, []);
    const getNavigationBarItems = callIfDisabled("getNavigationBarItems", 0, []);
    const getNavigationTree = callIfDisabled("getNavigationTree", 0, () => ({
      text: "",
      kind: "",
      kindModifiers: "",
      spans: [],
      nameSpan: void 0
    }));
    const getOutliningSpans = callIfDisabled("getOutliningSpans", 0, []);
    const getQuickInfoAtPosition = callIfDisabled("getQuickInfoAtPosition", 0, void 0);
    const getReferencesAtPosition = callIfDisabled("getReferencesAtPosition", 0, void 0);
    const getSemanticClassifications = callIfDisabled("getSemanticClassifications", 0, []);
    const getSemanticDiagnostics = callIfDisabled("getSemanticDiagnostics", 0, []);
    const getSignatureHelpItems = callIfDisabled("getSignatureHelpItems", 0, void 0);
    const getSpanOfEnclosingComment = callIfDisabled("getSpanOfEnclosingComment", 0, void 0);
    const getSuggestionDiagnostics = callIfDisabled("getSuggestionDiagnostics", 0, []);
    const getSyntacticDiagnostics = callIfDisabled("getSyntacticDiagnostics", 0, []);
    const getSyntacticClassifications = callIfDisabled("getSyntacticClassifications", 0, []);
    const getTodoComments = callIfDisabled("getTodoComments", 0, []);
    const getTypeDefinitionAtPosition = callIfDisabled("getTypeDefinitionAtPosition", 0, void 0);
    const prepareCallHierarchy = callIfDisabled("prepareCallHierarchy", 0, void 0);
    const provideCallHierarchyIncomingCalls = callIfDisabled("provideCallHierarchyIncomingCalls", 0, []);
    const provideCallHierarchyOutgoingCalls = callIfDisabled("provideCallHierarchyOutgoingCalls", 0, []);
    const provideInlayHints = callIfDisabled("provideInlayHints", 0, []);
    const toggleLineComment = callIfDisabled("toggleLineComment", 0, []);
    const toggleMultilineComment = callIfDisabled("toggleMultilineComment", 0, []);
    const uncommentSelection = callIfDisabled("uncommentSelection", 0, []);
    const getSupportedCodeFixes = callIfDisabled("getSupportedCodeFixes", 0, []);
    return {
      ...ls,
      commentSelection,
      findReferences,
      findRenameLocations,
      getApplicableRefactors,
      getBraceMatchingAtPosition,
      getBreakpointStatementAtPosition,
      getCodeFixesAtPosition,
      getCompilerOptionsDiagnostics,
      getCompletionEntryDetails,
      getCompletionEntrySymbol,
      getCompletionsAtPosition,
      getDefinitionAndBoundSpan,
      getDefinitionAtPosition,
      getDocCommentTemplateAtPosition,
      getDocumentHighlights,
      getEditsForFileRename,
      getEditsForRefactor,
      getEncodedSemanticClassifications,
      getEncodedSyntacticClassifications,
      getImplementationAtPosition,
      getJsxClosingTagAtPosition,
      getNameOrDottedNameSpan,
      getNavigateToItems,
      getNavigationBarItems,
      getNavigationTree,
      getOutliningSpans,
      getQuickInfoAtPosition,
      getReferencesAtPosition,
      getSemanticClassifications,
      getSemanticDiagnostics,
      getSignatureHelpItems,
      getSpanOfEnclosingComment,
      getSuggestionDiagnostics,
      getSyntacticClassifications,
      getSyntacticDiagnostics,
      getTodoComments,
      getTypeDefinitionAtPosition,
      prepareCallHierarchy,
      provideCallHierarchyIncomingCalls,
      provideCallHierarchyOutgoingCalls,
      provideInlayHints,
      toggleLineComment,
      toggleMultilineComment,
      uncommentSelection,
      getSupportedCodeFixes
    };
  }
  onConfigurationChanged(settings) {
    if (__privateGet(this, _loggingEnabled).call(this)) {
      __privateGet(this, _log).call(this, `onConfigurationChanged(${JSON.stringify(settings)})`);
    }
    updateSettings(__privateGet(this, _project), settings);
    __privateGet(this, _project).refreshDiagnostics();
  }
};
_project = new WeakMap();
_projectName = new WeakMap();
_denoEnabled = new WeakSet();
denoEnabled_fn = function() {
  var _a, _b, _c;
  const pluginSettings = projectSettings.get(__privateGet(this, _projectName));
  const enable = (_b = (_a = pluginSettings == null ? void 0 : pluginSettings.workspace) == null ? void 0 : _a.enable) != null ? _b : defaultSettings.enable;
  const hasDenoConfig = (_c = pluginSettings == null ? void 0 : pluginSettings.hasDenoConfig) != null ? _c : false;
  return enable != null ? enable : hasDenoConfig;
};
_fileNameDenoEnabled = new WeakSet();
fileNameDenoEnabled_fn = function(fileName) {
  var _a, _b, _c;
  if (process.platform === "win32") {
    fileName = fileName.replace(/\//g, "\\");
  }
  const settings = projectSettings.get(__privateGet(this, _projectName));
  if (settings == null ? void 0 : settings.pathFilters) {
    const pathFilter = settings.pathFilters.find(({ workspace }) => pathStartsWith(fileName, workspace));
    if (pathFilter) {
      for (const path2 of pathFilter.disabled) {
        if (pathStartsWith(fileName, path2)) {
          return false;
        }
      }
      if (pathFilter == null ? void 0 : pathFilter.enabled) {
        return pathFilter.enabled.some((path2) => pathStartsWith(fileName, path2));
      }
    }
  }
  return (_c = (_b = (_a = settings == null ? void 0 : settings.documents) == null ? void 0 : _a[fileName]) == null ? void 0 : _b.settings.enable) != null ? _c : __privateMethod(this, _denoEnabled, denoEnabled_fn).call(this);
};
_log = new WeakMap();
_loggingEnabled = new WeakMap();
function init() {
  console.log(`INIT typescript-deno-plugin`);
  return new Plugin();
}
var PARENT_RELATIVE_REGEX = os.platform() === "win32" ? /\.\.(?:[/\\]|$)/ : /\.\.(?:\/|$)/;
function pathStartsWith(child, parent) {
  if (path.isAbsolute(child) !== path.isAbsolute(parent)) {
    return false;
  }
  const relative2 = path.relative(parent, child);
  return !relative2.match(PARENT_RELATIVE_REGEX);
}
module.exports = init;

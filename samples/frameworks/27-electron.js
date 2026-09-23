/**
 * Electron framework tour.
 *
 * Covers the main process, BrowserWindow lifecycle, IPC,
 * preload scripts, context isolation, menus and auto-updates.
 */

const { app, BrowserWindow, Menu, dialog, ipcMain, shell } = require("electron");
const path = require("node:path");

/** @type {BrowserWindow | null} */
let mainWindow = null;

const isDev = !app.isPackaged;
const isMac = process.platform === "darwin";

/**
 * Creates the application window.
 *
 * @returns {BrowserWindow} the newly created window
 */
function createWindow() {
  const window = new BrowserWindow({
    width: 1280,
    height: 800,
    minWidth: 640,
    show: false,
    titleBarStyle: isMac ? "hiddenInset" : "default",
    backgroundColor: "#1f2335",
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
      contextIsolation: true, // inline comment
      nodeIntegration: false,
      sandbox: true,
    },
  });

  window.once("ready-to-show", () => window.show());

  window.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: "deny" };
  });

  if (isDev) {
    window.loadURL("http://localhost:5173");
    window.webContents.openDevTools({ mode: "detach" });
  } else {
    window.loadFile(path.join(__dirname, "../dist/index.html"));
  }

  return window;
}

function buildMenu() {
  const template = [
    ...(isMac ? [{ role: "appMenu" }] : []),
    {
      label: "File",
      submenu: [
        {
          label: "Open…",
          accelerator: "CmdOrCtrl+O",
          async click() {
            const { canceled, filePaths } = await dialog.showOpenDialog({
              properties: ["openFile", "multiSelections"],
              filters: [{ name: "Logs", extensions: ["log", "txt"] }],
            });
            if (!canceled) mainWindow?.webContents.send("files:opened", filePaths);
          },
        },
        { type: "separator" },
        { role: isMac ? "close" : "quit" },
      ],
    },
    { role: "viewMenu" },
  ];

  Menu.setApplicationMenu(Menu.buildFromTemplate(template));
}

// IPC handlers — invoked from the renderer via the preload bridge.
ipcMain.handle("articles:find", async (_event, id) => {
  if (typeof id !== "number") throw new TypeError("id must be a number");
  return { id, title: "hello", likeCount: 0 };
});

ipcMain.on("window:minimise", () => mainWindow?.minimize());

app.whenReady().then(() => {
  mainWindow = createWindow();
  buildMenu();

  app.on("activate", () => {
    if (BrowserWindow.getAllWindows().length === 0) mainWindow = createWindow();
  });
});

app.on("window-all-closed", () => {
  if (!isMac) app.quit();
});

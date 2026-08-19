import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.janhesters.tasks"

  property bool taskwarriorAvailable: true
  property bool taskwarriorTuiAvailable: true
  property bool taskReadError: false
  property int total: 0
  property int actionable: 0
  property string taskTooltip: "Loading Taskwarrior tasks..."

  readonly property bool showWhenEmpty: setting("showWhenEmpty", true) === true
  readonly property int refreshIntervalSec: Math.max(10, Number(setting("refreshIntervalSec", 60)) || 60)
  readonly property string helperPath: localPath(Qt.resolvedUrl("tasks-data"))

  function localPath(url) {
    var value = String(url)
    if (value.indexOf("file://") === 0) return decodeURIComponent(value.substring(7))
    return value
  }

  function refresh() {
    if (!taskProcess.running) taskProcess.running = true
  }

  function applyOutput(output) {
    try {
      var data = JSON.parse(String(output || "{}"))
      root.taskwarriorAvailable = data.available === true
      root.taskwarriorTuiAvailable = data.tuiAvailable === true
      root.taskReadError = data.readError === true
      root.total = Math.max(0, Number(data.total) || 0)
      root.actionable = Math.max(0, Number(data.actionable) || 0)
      root.taskTooltip = String(data.tooltip || "No pending tasks")
    } catch (error) {
      root.taskwarriorAvailable = false
      root.taskwarriorTuiAvailable = false
      root.taskReadError = true
      root.total = 0
      root.actionable = 0
      root.taskTooltip = "Could not read Taskwarrior tasks"
      console.warn(root.moduleName + ": invalid tasks-data output:", error)
    }
  }

  function openTasks() {
    if (!root.bar) return

    if (!root.taskwarriorAvailable) {
      root.bar.run("omarchy launch floating terminal with presentation \"omarchy pkg add task taskwarrior-tui && omarchy-shell io.github.janhesters.tasks refresh\"")
    } else if (!root.taskwarriorTuiAvailable) {
      root.bar.run("omarchy launch floating terminal with presentation \"omarchy pkg add taskwarrior-tui && omarchy-shell io.github.janhesters.tasks refresh\"")
    } else {
      root.bar.run("omarchy launch or focus tui taskwarrior-tui")
    }
  }

  function primaryActionLabel() {
    if (!root.taskwarriorAvailable) return "install Taskwarrior"
    if (!root.taskwarriorTuiAvailable) return "install taskwarrior-tui"
    return "open taskwarrior-tui"
  }

  visible: !taskwarriorAvailable || !taskwarriorTuiAvailable || taskReadError || total > 0 || showWhenEmpty
  implicitWidth: visible ? button.implicitWidth : 0
  implicitHeight: visible ? button.implicitHeight : 0

  IpcHandler {
    target: "io.github.janhesters.tasks"

    function refresh(): void {
      root.broadcast("refresh")
    }
  }

  Process {
    id: taskProcess
    command: [root.helperPath]

    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyOutput(text)
    }

    onExited: function(exitCode) {
      if (exitCode !== 0) {
        root.taskwarriorAvailable = false
        root.taskwarriorTuiAvailable = false
        root.taskReadError = true
        root.taskTooltip = "Could not read Taskwarrior tasks"
      }
    }
  }

  Timer {
    interval: root.refreshIntervalSec * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.taskwarriorAvailable && !root.taskReadError
      ? (root.total > 0 ? "\uf0ae  " + String(root.actionable > 0 ? root.actionable : root.total) : "\uf0ae")
      : "\uf071"
    fontSize: Style.font.caption
    active: root.actionable > 0 || !root.taskwarriorAvailable || !root.taskwarriorTuiAvailable || root.taskReadError
    activeColor: Color.urgent
    useActiveColor: true
    dimmed: root.taskwarriorAvailable && root.taskwarriorTuiAvailable && !root.taskReadError && root.total === 0
    tooltipText: root.taskTooltip + "\n\nLeft-click: " + root.primaryActionLabel() + " | Right-click: refresh"
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) root.refresh()
      else if (buttonCode === Qt.LeftButton) root.openTasks()
    }
  }
}

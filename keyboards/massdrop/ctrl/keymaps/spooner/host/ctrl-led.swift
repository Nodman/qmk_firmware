// ctrl-led: set Massdrop CTRL status lights over Raw HID (spooner keymap).
// Build: xcrun swiftc -O ctrl-led.swift -o ~/.local/bin/ctrl-led
import Foundation
import IOKit.hid

// MARK: - Keyboard

let vendorID = 0x04D8, productID = 0xEED2, usagePage = 0xFF60, usage = 0x61
let reportSize = 32

enum Mode: UInt8 { case off = 0, solid, blink, fast }
enum Command: UInt8 { case set = 0x01, clearAll = 0x02 }

// LED index per key, in config_led.c order.
let keyLEDs: [String: Int] = {
    var m: [String: Int] = ["esc": 0, "prtsc": 13, "scrlk": 14, "pause": 15, "mute": 15,
                            "grave": 16, "minus": 27, "equal": 28, "bspc": 29, "ins": 30, "home": 31, "pgup": 32,
                            "tab": 33, "lbrc": 44, "rbrc": 45, "bsls": 46, "del": 47, "end": 48, "pgdn": 49,
                            "caps": 50, "scln": 60, "quot": 61, "enter": 62,
                            "lshift": 63, "comm": 71, "dot": 72, "slsh": 73, "rshift": 74, "up": 75,
                            "lctrl": 76, "lgui": 77, "lalt": 78, "space": 79, "ralt": 80, "fn": 81, "menu": 82,
                            "rctrl": 83, "left": 84, "down": 85, "right": 86]
    for i in 1...12 { m["f\(i)"] = i }
    for i in 1...9 { m["\(i)"] = 16 + i }
    m["0"] = 26
    for (i, c) in "qwertyuiop".enumerated() { m[String(c)] = 34 + i }
    for (i, c) in "asdfghjkl".enumerated() { m[String(c)] = 51 + i }
    for (i, c) in "zxcvbnm".enumerated() { m[String(c)] = 64 + i }
    return m
}()

let colors: [String: (UInt8, UInt8, UInt8)] = [
    "red": (255, 0, 0), "orange": (255, 100, 0), "yellow": (255, 200, 0), "green": (0, 255, 0),
    "cyan": (0, 255, 255), "blue": (0, 0, 255), "purple": (160, 0, 255), "magenta": (255, 0, 255),
    "white": (255, 255, 255), "off": (0, 0, 0),
]

func openKeyboards() -> [IOHIDDevice] {
    let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
    let match: [String: Any] = [kIOHIDVendorIDKey: vendorID, kIOHIDProductIDKey: productID,
                                kIOHIDPrimaryUsagePageKey: usagePage, kIOHIDPrimaryUsageKey: usage]
    IOHIDManagerSetDeviceMatching(manager, match as CFDictionary)
    guard let devices = IOHIDManagerCopyDevices(manager) as? Set<IOHIDDevice> else { return [] }
    return devices.filter { IOHIDDeviceOpen($0, IOOptionBits(kIOHIDOptionsTypeNone)) == kIOReturnSuccess }
}

@discardableResult
func send(_ devices: [IOHIDDevice], _ bytes: [UInt8]) -> Bool {
    var report = [UInt8](repeating: 0, count: reportSize)
    report.replaceSubrange(0..<bytes.count, with: bytes)
    var ok = !devices.isEmpty
    for device in devices {
        ok = IOHIDDeviceSetReport(device, kIOHIDReportTypeOutput, 0, report, report.count) == kIOReturnSuccess && ok
    }
    return ok
}

func setLED(_ devices: [IOHIDDevice], _ led: Int, _ color: (UInt8, UInt8, UInt8), _ mode: Mode) {
    send(devices, [Command.set.rawValue, UInt8(led), color.0, color.1, color.2, mode.rawValue])
}

func parseLED(_ s: String) -> Int? {
    keyLEDs[s.lowercased()] ?? Int(s.dropFirst(s.hasPrefix("#") ? 1 : 0)).flatMap { $0 < 119 ? $0 : nil }
}

func parseColor(_ s: String) -> (UInt8, UInt8, UInt8)? {
    if let c = colors[s.lowercased()] { return c }
    let hex = s.hasPrefix("#") ? String(s.dropFirst()) : s
    guard hex.count == 6, let v = UInt32(hex, radix: 16) else { return nil }
    return (UInt8(v >> 16 & 0xFF), UInt8(v >> 8 & 0xFF), UInt8(v & 0xFF))
}

// MARK: - Claude Code sessions

// Summary on Esc, one F key per session (F1..F9).
let summaryLED = 0
let slotLEDs = Array(1...9)
let staleSeconds = 24.0 * 3600
// "working" with no events this long and no tool running shows as idle.
let stuckWorkingSeconds = 10.0 * 60

enum State: String, Codable { case idle, working, question }

let stateLooks: [State: ((UInt8, UInt8, UInt8), Mode)] = [
    .idle: (colors["green"]!, .solid),
    .working: (colors["orange"]!, .blink),
    .question: (colors["red"]!, .fast),
]

struct Session: Codable {
    var slot: Int?
    var state: State
    var pid: Int32
    var cwd: String
    var updated: Double
    var toolRunning: Bool?
}

let stateDir = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".local/state/ctrl-led")
let stateFile = stateDir.appendingPathComponent("claude.json")
let logFile = stateDir.appendingPathComponent("events.log")
let logMaxBytes = 512 * 1024

// Append one line; keep the newest half when the file gets too big. Call under the lock.
func log(_ line: String) {
    let stamp = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime, .withFractionalSeconds])
    var data = (try? Data(contentsOf: logFile)) ?? Data()
    if data.count > logMaxBytes {
        data = data.suffix(logMaxBytes / 2)
        if let nl = data.firstIndex(of: 0x0A) { data = data.suffix(from: nl + 1) }
    }
    data.append("\(stamp) \(line)\n".data(using: .utf8)!)
    try? data.write(to: logFile, options: .atomic)
}

func withLockedSessions(_ body: (inout [String: Session]) -> Void) {
    try? FileManager.default.createDirectory(at: stateDir, withIntermediateDirectories: true)
    let lock = open(stateDir.appendingPathComponent("claude.lock").path, O_CREAT | O_RDWR, 0o644)
    defer { close(lock) }
    flock(lock, LOCK_EX)
    var sessions = (try? JSONDecoder().decode([String: Session].self, from: Data(contentsOf: stateFile))) ?? [:]
    body(&sessions)
    if let data = try? JSONEncoder().encode(sessions) {
        try? data.write(to: stateFile, options: .atomic)
    }
}

func parentPID(_ pid: pid_t) -> pid_t? {
    var info = kinfo_proc()
    var size = MemoryLayout<kinfo_proc>.stride
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
    guard sysctl(&mib, 4, &info, &size, nil, 0) == 0, size > 0 else { return nil }
    return info.kp_eproc.e_ppid
}

func isClaude(_ pid: pid_t) -> Bool {
    var path = [CChar](repeating: 0, count: 4096)
    guard proc_pidpath(pid, &path, 4096) > 0 else { return false }
    let p = String(cString: path)
    return p.contains("/claude/versions/") || (p as NSString).lastPathComponent == "claude"
}

// The Claude process that ran this hook, or 0 if not found.
func claudePID() -> Int32 {
    var pid = getppid()
    for _ in 0..<6 {
        if isClaude(pid) { return pid }
        guard let parent = parentPID(pid), parent > 1 else { break }
        pid = parent
    }
    return 0
}

func processArgs(_ pid: pid_t) -> [String] {
    var mib: [Int32] = [CTL_KERN, KERN_PROCARGS2, pid]
    var size = 0
    guard sysctl(&mib, 3, nil, &size, nil, 0) == 0, size > 4 else { return [] }
    var buf = [UInt8](repeating: 0, count: size)
    guard sysctl(&mib, 3, &buf, &size, nil, 0) == 0 else { return [] }
    // Layout: argc (Int32), exec path, NUL padding, then argc NUL-terminated args.
    let argc = Int(buf.withUnsafeBytes { $0.load(as: Int32.self) })
    var i = 4
    while i < size && buf[i] != 0 { i += 1 }
    while i < size && buf[i] == 0 { i += 1 }
    var args: [String] = []
    while args.count < argc && i < size {
        let start = i
        while i < size && buf[i] != 0 { i += 1 }
        args.append(String(decoding: buf[start..<i], as: UTF8.self))
        i += 1
    }
    return args
}

// Session this process resumed (`--resume <id or path/id.jsonl>`). A fork gets a new id,
// and the old id never sends SessionEnd.
func resumedSessionID(_ pid: pid_t) -> String? {
    let args = processArgs(pid)
    var value: String?
    for (i, a) in args.enumerated() {
        if (a == "--resume" || a == "-r"), i + 1 < args.count { value = args[i + 1] }
        if a.hasPrefix("--resume=") { value = String(a.dropFirst("--resume=".count)) }
    }
    guard let value, !value.isEmpty else { return nil }
    return ((value as NSString).lastPathComponent as NSString).deletingPathExtension
}

func shownState(_ s: Session) -> State {
    let quiet = Date().timeIntervalSince1970 - s.updated
    if s.state == .working && !(s.toolRunning ?? false) && quiet > stuckWorkingSeconds { return .idle }
    return s.state
}

func isAlive(_ s: Session) -> Bool {
    if s.pid > 0 { return kill(s.pid, 0) == 0 || errno == EPERM }
    return Date().timeIntervalSince1970 - s.updated < staleSeconds
}

func newState(event: String, input: [String: Any], current: State) -> State? {
    let tool = input["tool_name"] as? String ?? ""
    let kind = input["notification_type"] as? String ?? ""
    switch event {
    case "SessionStart", "Stop", "StopFailure": return .idle
    case "UserPromptSubmit", "PostToolUse", "PostToolUseFailure", "PermissionDenied": return .working
    case "PreToolUse": return tool == "AskUserQuestion" ? .question : .working
    case "PermissionRequest": return .question
    case "Notification":
        if ["permission_prompt", "elicitation_dialog", "elicitation_url_dialog", "agent_needs_input"].contains(kind) { return .question }
        // Stop does not fire on user interrupt; the idle prompt (~60 s later) ends a stuck "working".
        if kind == "idle_prompt" && current == .working { return .idle }
        return nil
    default: return nil
    }
}

func render(_ sessions: [String: Session]) {
    let devices = openKeyboards()
    guard !devices.isEmpty else { return }
    let states = sessions.values.map(shownState)
    let summary: State? = states.contains(.question) ? .question : states.contains(.working) ? .working : states.isEmpty ? nil : .idle
    if let s = summary, let look = stateLooks[s] {
        setLED(devices, summaryLED, look.0, look.1)
    } else {
        setLED(devices, summaryLED, colors["off"]!, .off)
    }
    for (i, led) in slotLEDs.enumerated() {
        if let s = sessions.values.first(where: { $0.slot == i + 1 }), let look = stateLooks[shownState(s)] {
            setLED(devices, led, look.0, look.1)
        } else {
            setLED(devices, led, colors["off"]!, .off)
        }
    }
}

func slotKeyName(_ slot: Int) -> String { "F\(slot)" }

// Hook entry point. Never fails: a broken keyboard must not block Claude.
func claudeHook() {
    let data = FileHandle.standardInput.readDataToEndOfFile()
    guard let input = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
          let id = input["session_id"] as? String,
          let event = input["hook_event_name"] as? String else { return }
    var message: String?
    let tool = input["tool_name"] as? String ?? input["notification_type"] as? String ?? ""
    withLockedSessions { sessions in
        for (deadID, s) in sessions where !isAlive(s) {
            log("\(deadID.prefix(8)) pruned dead pid \(s.pid) slot \(s.slot.map(slotKeyName) ?? "-")")
            sessions[deadID] = nil
        }
        let before = sessions[id]?.state.rawValue ?? "new"
        if event == "SessionEnd" {
            sessions[id] = nil
            log("\(id.prefix(8)) \(event) \(before) -> removed")
        } else {
            var s = sessions[id] ?? Session(slot: nil, state: .idle, pid: claudePID(), cwd: input["cwd"] as? String ?? "", updated: 0)
            if s.pid > 0, let old = resumedSessionID(s.pid), old != id, let ghost = sessions[old] {
                log("\(old.prefix(8)) replaced by fork \(id.prefix(8)), freed key \(ghost.slot.map(slotKeyName) ?? "-")")
                sessions[old] = nil
            }
            if s.slot == nil {
                let used = Set(sessions.values.compactMap(\.slot))
                s.slot = (1...slotLEDs.count).first { !used.contains($0) }
                if event == "SessionStart" {
                    message = s.slot.map { "Keyboard status key: \(slotKeyName($0))" } ?? "Keyboard status: all keys in use"
                }
            }
            if let state = newState(event: event, input: input, current: s.state) { s.state = state }
            if event == "PreToolUse" {
                s.toolRunning = true
            } else if ["PostToolUse", "PostToolUseFailure", "PermissionDenied", "UserPromptSubmit", "Stop", "StopFailure"].contains(event) {
                s.toolRunning = false
            }
            s.updated = Date().timeIntervalSince1970
            sessions[id] = s
            log("\(id.prefix(8)) \(event) \(tool) \(before) -> \(s.state.rawValue) key \(s.slot.map(slotKeyName) ?? "-") pid \(s.pid)")
        }
        render(sessions)
    }
    if let message, let json = try? JSONSerialization.data(withJSONObject: ["systemMessage": message]) {
        FileHandle.standardOutput.write(json)
    }
}

func claudeList() {
    withLockedSessions { sessions in
        sessions = sessions.filter { isAlive($0.value) }
        if sessions.isEmpty { print("No Claude sessions.") }
        let now = Date().timeIntervalSince1970
        for (id, s) in sessions.sorted(by: { ($0.value.slot ?? 99) < ($1.value.slot ?? 99) }) {
            let shown = shownState(s) == s.state ? s.state.rawValue : "\(shownState(s).rawValue)*"
            print("key \(s.slot.map(slotKeyName) ?? "-")  \(shown.padding(toLength: 9, withPad: " ", startingAt: 0))  \(id.prefix(8))  pid \(s.pid)  \(Int(now - s.updated))s ago  \(s.cwd)")
        }
        if sessions.values.contains(where: { shownState($0) != $0.state }) {
            print("* working with no events for \(Int(stuckWorkingSeconds / 60)) min, shown as idle")
        }
        render(sessions)
    }
}

// MARK: - CLI

let usageText = """
Usage:
  ctrl-led set <key> <color> [solid|blink|fast]   key: esc, f1, 1, q, 0..118; color: red, orange, ..., #RRGGBB
  ctrl-led off <key>
  ctrl-led clear                                  turn off all status lights
  ctrl-led claude                                 Claude Code hook: reads hook JSON on stdin
  ctrl-led claude list                            show sessions and their keys, refresh lights
  ctrl-led claude reset                           forget all sessions, turn off lights
  Event log: ~/.local/state/ctrl-led/events.log
"""

func fail(_ msg: String) -> Never {
    FileHandle.standardError.write((msg + "\n").data(using: .utf8)!)
    exit(1)
}

func requireKeyboard() -> [IOHIDDevice] {
    let devices = openKeyboards()
    if devices.isEmpty { fail("Keyboard not found (Massdrop CTRL with Raw HID firmware).") }
    return devices
}

let args = Array(CommandLine.arguments.dropFirst())
switch args.first {
case "set":
    guard args.count >= 3, let led = parseLED(args[1]), let color = parseColor(args[2]) else { fail(usageText) }
    let mode: Mode = ["blink": .blink, "fast": .fast][args.count > 3 ? args[3] : ""] ?? .solid
    setLED(requireKeyboard(), led, color, mode)
case "off":
    guard args.count >= 2, let led = parseLED(args[1]) else { fail(usageText) }
    setLED(requireKeyboard(), led, colors["off"]!, .off)
case "clear":
    send(requireKeyboard(), [Command.clearAll.rawValue])
case "claude":
    switch args.dropFirst().first {
    case nil: claudeHook()
    case "list": claudeList()
    case "reset":
        withLockedSessions { sessions in
            sessions = [:]
            render(sessions)
        }
    default: fail(usageText)
    }
default:
    print(usageText)
}

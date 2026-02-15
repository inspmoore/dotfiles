import Foundation

let configDir = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent(".config/zellij")
let themeConfigPath = configDir.appendingPathComponent("theme-sync.conf")
let zellijConfigPath = configDir.appendingPathComponent("config.kdl")

var lastAppliedTheme: String?

func log(_ message: String) {
    FileHandle.standardError.write("\(message)\n".data(using: .utf8)!)
}

func readThemeConfig() -> (dark: String, light: String)? {
    guard let content = try? String(contentsOf: themeConfigPath, encoding: .utf8) else {
        return nil
    }

    var dark: String?
    var light: String?

    for line in content.components(separatedBy: .newlines) {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("dark=") {
            dark = String(trimmed.dropFirst(5))
        } else if trimmed.hasPrefix("light=") {
            light = String(trimmed.dropFirst(6))
        }
    }

    guard let darkTheme = dark, let lightTheme = light else {
        return nil
    }

    return (darkTheme, lightTheme)
}

func isDarkMode() -> Bool {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
    process.arguments = ["read", "-g", "AppleInterfaceStyle"]

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = FileHandle.nullDevice

    defer {
        try? pipe.fileHandleForReading.close()
    }

    do {
        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            return output.trimmingCharacters(in: .whitespacesAndNewlines) == "Dark"
        }
    } catch {}

    return false
}

func updateZellijTheme(_ themeName: String) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/sed")
    process.arguments = [
        "-i", "",
        "s/^theme \".*\"$/theme \"\(themeName)\"/",
        zellijConfigPath.path
    ]

    do {
        try process.run()
        process.waitUntilExit()
        lastAppliedTheme = themeName
        log("[\(Date())] Updated theme to: \(themeName)")
    } catch {
        log("[\(Date())] Error: \(error)")
    }
}

func syncTheme() {
    guard let themes = readThemeConfig() else { return }

    let targetTheme = isDarkMode() ? themes.dark : themes.light

    if lastAppliedTheme != targetTheme {
        updateZellijTheme(targetTheme)
    }
}

// Handle termination gracefully
signal(SIGTERM) { _ in exit(0) }
signal(SIGINT) { _ in exit(0) }

log("[\(Date())] Started (polling every 5s)")

// Initial sync
syncTheme()

// Poll every 5 seconds
while true {
    sleep(5)
    syncTheme()
}

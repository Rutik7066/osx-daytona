import enum VersionSpecifier.VersionSpecifier
import BuildRunner
import ArgumentParser
import Foundation
import struct GlobalOptions.GlobalOptions
import Models

public struct BuildCommand: ParsableCommand {

    public static var configuration = CommandConfiguration(
        commandName: "build",
        abstract: "Build macOS, iOS, and tvOS targets."
    )

    @Argument()
    var platform: Platform

    @Option(name: [.short, .customLong("version")], default: .latest)
    var versionSpecifier: VersionSpecifier

    @Option()
    var project: String?

    @Option()
    var workspace: String?

    @Option()
    var scheme: String

    @OptionGroup()
    var globalOptions: GlobalOptions

    public init() {}

    public func run() throws {
        try BuildRunner.build(
            platform: platform,
            versionSpecifier: versionSpecifier,
            project: project.map { URL(fileURLWithPath: $0, isDirectory: true) },
            workspace: workspace.map { URL(fileURLWithPath: $0, isDirectory: true) },
            scheme: scheme,
            enableVerboseLogging: globalOptions.verbose
        )
    }

}
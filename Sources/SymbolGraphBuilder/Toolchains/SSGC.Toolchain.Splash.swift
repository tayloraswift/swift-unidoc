import SemanticVersions
import SymbolGraphs
import Symbols
import System_

extension SSGC.Toolchain
{
    @frozen public
    struct Splash
    {
        public
        let commit:SymbolGraphMetadata.Commit?
        public
        let triple:Symbol.Triple
        public
        let swift:SwiftVersion

        private
        init(commit:SymbolGraphMetadata.Commit?,
            triple:Symbol.Triple,
            swift:SwiftVersion)
        {
            self.commit = commit
            self.triple = triple
            self.swift = swift
        }
    }
}
extension SSGC.Toolchain.Splash
{
    public
    init(parsing splash:String) throws
    {
        //  Splash should consist of two complete lines and a final newline. If the final
        //  newline isn’t present, the output was clipped.
        let lines:[Substring] = splash.split(separator: "\n", omittingEmptySubsequences: false)
        guard lines.count == 3
        else
        {
            throw SSGC.ToolchainError.malformedSplash
        }

        let toolchain:[Substring] = lines[0].split(separator: " ")
        let triple:[Substring] = lines[1].split(separator: " ")

        guard
            triple.count == 2,
            triple[0] == "Target:",
        let triple:Symbol.Triple = .init(triple[1])
        else
        {
            throw SSGC.ToolchainError.malformedSplash
        }

        var k:Int = toolchain.endIndex
        for (i, j):(Int, Int) in zip(toolchain.indices, toolchain.indices.dropFirst())
        {
            if  toolchain[i ... j] == ["Swift", "version"]
            {
                k = toolchain.index(after: j)
                break
            }
        }
        if  k == toolchain.endIndex
        {
            throw SSGC.ToolchainError.malformedSplash
        }

        let id:SwiftVersion
        if  let version:NumericVersion = .init(toolchain[k])
        {
            id = .init(version: PatchVersion.init(padding: version))
        }

        else if
            let version:MinorVersion = .init(toolchain[k].prefix { $0 != "-" })
        {
            id = .init(
                version: .v(version.components.major, version.components.minor, 0),
                nightly: .DEVELOPMENT_SNAPSHOT)
        }
        else
        {
            throw SSGC.ToolchainError.malformedSwiftVersion
        }

        let commit:SymbolGraphMetadata.Commit?
        if  case nil = id.nightly,
            let word:Substring = toolchain[toolchain.index(after: k)...].first
        {
            commit = .parenthesizedSwiftRelease(word)
        }
        else
        {
            commit = nil
        }

        self.init(commit: commit, triple: triple, swift: id)
    }

    public
    init(running command:String) throws
    {
        let (readable, writable):(FileDescriptor, FileDescriptor) = try FileDescriptor.pipe()

        defer
        {
            try? writable.close()
            try? readable.close()
        }

        try SystemProcess.init(command: command, "--version", stdout: writable)()
        try self.init(parsing: try readable.read(buffering: 1024))
    }
}

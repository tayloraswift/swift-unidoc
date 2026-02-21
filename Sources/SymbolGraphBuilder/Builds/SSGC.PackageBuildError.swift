extension SSGC {
    @frozen public enum PackageBuildError: Error {
        case swift_package_update       (Int32, [String])
        case swift_build                (Int32, [String])
        case swift_symbolgraph_extract  (Int32, [String])
    }
}
extension SSGC.PackageBuildError: CustomStringConvertible {
    public var description: String {
        let tool: String
        let exit: Int32
        let command: [String]

        switch self {
        case .swift_package_update(let code, let invocation):
            tool = "swift package update"
            exit = code
            command = invocation

        case .swift_build(let code, let invocation):
            tool = "swift build"
            exit = code
            command = invocation

        case .swift_symbolgraph_extract(let code, let invocation):
            tool = "swift symbolgraph extract"
            exit = code
            command = invocation
        }

        return "\(tool) exited with \(exit) (\(command.joined(separator: " ")))"
    }
}

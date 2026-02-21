import JSON
import Symbols

extension Unidoc {
    /// An `EditionStateReport` summarizes what you would see on a package’s `/tags` page, in a
    /// more machine-readable format.
    @frozen public struct EditionStateReport: Sendable {
        public let id: Edition
        public let volume: Symbol.Volume?
        public let build: BuildStatus?
        public let graph: Graph?

        @inlinable public init(
            id: Edition,
            volume: Symbol.Volume?,
            build: BuildStatus?,
            graph: Graph?
        ) {
            self.id = id
            self.volume = volume
            self.build = build
            self.graph = graph
        }
    }
}
extension Unidoc.EditionStateReport {
    public var phase: Phase {
        if  let graph: Graph = self.graph,
            case nil = graph.action {
            return .ACTIVE
        }

        guard
        let build: Unidoc.BuildStatus = self.build else {
            return .DEFAULT
        }

        if  let failure: Unidoc.BuildFailure = build.failure {
            switch failure {
            case .noValidVersion:                       return .SKIPPED
            case .failedToCloneRepository:              return .FAILED_CLONE_REPOSITORY
            case .failedToReadManifest:                 return .FAILED_READ_MANIFEST
            case .failedToReadManifestForDependency:    return .FAILED_READ_MANIFEST
            case .failedToResolveDependencies:          return .FAILED_RESOLVE_DEPENDENCIES
            case .failedToBuild:                        return .FAILED_COMPILE_CODE
            case .failedToExtractSymbolGraph:           return .FAILED_EXTRACT_SYMBOLS
            case .failedToLoadSymbolGraph:              return .FAILED_COMPILE_DOCS
            case .failedToLinkSymbolGraph:              return .FAILED_COMPILE_DOCS
            case .failedForUnknownReason:               return .FAILED_UNKNOWN
            case .killed:                               return .FAILED_UNKNOWN
            }
        } else if
            let stage: Unidoc.BuildStage = build.pending {
            switch stage {
            case .initializing:                         return .MATCHING
            case .cloningRepository:                    return .ASSIGNED_CLONING_REPOSITORY
            case .resolvingDependencies:                return .ASSIGNED_BUILDING
            case .compilingCode:                        return .ASSIGNED_BUILDING
            }
        } else {
            return self.id == build.request ? .QUEUED : .QUEUED_DIFFERENT_VERSION
        }
    }
}
extension Unidoc.EditionStateReport {
    @frozen public enum CodingKey: String, Sendable {
        case id
        case volume
        case build
        case graph
        case phase
    }
}
extension Unidoc.EditionStateReport: JSONObjectEncodable {
    public func encode(to json: inout JSON.ObjectEncoder<CodingKey>) {
        json[.id] = self.id.version
        json[.volume] = self.volume
        json[.build] = self.build
        json[.graph] = self.graph
        json[.phase] = self.phase
    }
}
extension Unidoc.EditionStateReport: JSONObjectDecodable {
    public init(json: JSON.ObjectDecoder<CodingKey>) throws {
        self.init(
            id: try json[.id].decode(),
            volume: try json[.volume]?.decode(),
            build: try json[.build]?.decode(),
            graph: try json[.graph]?.decode()
        )
    }
}

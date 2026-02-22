import PackageMetadata
import SymbolGraphs
import Symbols
import UnixTime

extension SSGC.PackageBuild {
    @frozen public enum ID: Hashable, Sendable {
        /// An unversioned SwiftPM build.
        case unversioned(Symbol.Package)
        /// A versioned SwiftPM build.
        case versioned(SPM.DependencyPin, ref: String, date: UnixMillisecond)
    }
}
extension SSGC.PackageBuild.ID {
    var commit: SymbolGraphMetadata.Commit? {
        guard case .versioned(let pin, ref: let name, date: let date) = self else {
            return nil
        }

        return .init(name: name, sha1: pin.revision, date: date)
    }

    var package: Symbol.Package {
        switch self {
        case .unversioned(let id):      id
        case .versioned(let pin, _, _): pin.identity
        }
    }
    var pin: SPM.DependencyPin? {
        switch self {
        case .unversioned:              nil
        case .versioned(let pin, _, _): pin
        }
    }
}

import Symbols

extension SSGC.Extension {
    public enum BlockError: Equatable, Error {
        case duplicate(Symbol.Block)
        case unclaimed(Symbol.Block)
    }
}
extension SSGC.Extension.BlockError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .duplicate(let id):
            "Duplicate extension block symbol '\(id)'"

        case .unclaimed(let id):
            "Extension block '\(id)' is not claimed by any type in its colony."
        }
    }
}

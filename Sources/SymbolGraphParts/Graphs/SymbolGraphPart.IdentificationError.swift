import Symbols

extension SymbolGraphPart {
    public enum IdentificationError: Error, Equatable, Sendable {
        case filename(String)
    }
}
extension SymbolGraphPart.IdentificationError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .filename(let filename):
            "invalid filename: \(filename)"
        }
    }
}

import Symbols

extension SSGC {
    public enum UndefinedSymbolError: Equatable, Error, Sendable {
        case declaration(Symbol.Decl)
        case `extension`(Symbol.Block)
    }
}
extension SSGC.UndefinedSymbolError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .extension(let symbol):
            "Undefined extension block '\(symbol)'"
        case .declaration(let symbol):
            "Undefined declaration '\(symbol)'"
        }
    }
}

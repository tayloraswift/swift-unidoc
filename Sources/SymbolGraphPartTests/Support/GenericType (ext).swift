import Signatures
import Symbols

extension GenericType<Symbol.Decl>
{
    static var Equatable:Self { .init(spelling: "Equatable", nominal: "sSQ") }
    static var Sequence:Self { .init(spelling: "Sequence", nominal: "sST") }
}

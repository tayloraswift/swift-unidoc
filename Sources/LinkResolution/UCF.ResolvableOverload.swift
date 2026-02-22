import Symbols
import UCF

extension UCF {
    public protocol ResolvableOverload: Identifiable<Symbol.Decl>, Sendable {
        var traits: DisambiguationTraits { get }

        var documented: Bool { get }
        var inherited: Bool { get }
    }
}

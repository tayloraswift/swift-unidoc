import Symbols

public
protocol SymbolRelationship<Source, Target>:Equatable, Sendable
{
    associatedtype Source:Hashable, Equatable, Sendable
    associatedtype Target:Hashable, Equatable, Sendable

    var origin:Symbol.Decl? { get }
    var source:Source { get }
    var target:Target { get }
}

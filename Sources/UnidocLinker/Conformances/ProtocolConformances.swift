import Signatures
import SymbolGraphs
import Unidoc
import UnidocDiagnostics

/// Describes a single type’s protocol conformances. Depending on how the type is being used,
/// the lists may or may not be exhaustive.
struct ProtocolConformances<Culture>
{
    private
    var table:[Unidoc.Scalar: [ProtocolConformance<Culture>]]

    private
    init(table:[Unidoc.Scalar: [ProtocolConformance<Culture>]])
    {
        self.table = table
    }
}
extension ProtocolConformances:Sendable where Culture:Sendable
{
}
extension ProtocolConformances
{
    /// Yields all known conformances to the specified protocol. This subscript returns an empty
    /// list if no conformances are known to exist. It can also return more than one conformance
    /// if multiple modules declare conformances to the same protocol.
    subscript(to protocol:Unidoc.Scalar) -> [ProtocolConformance<Culture>]
    {
        _read
        {
            yield  self.table[`protocol`, default: []]
        }
        _modify
        {
            yield &self.table[`protocol`, default: []]
        }
    }
}
extension ProtocolConformances:Sequence
{
    func makeIterator() -> Dictionary<Unidoc.Scalar, [ProtocolConformance<Culture>]>.Iterator
    {
        self.table.makeIterator()
    }
}
extension ProtocolConformances:ExpressibleByDictionaryLiteral
{
    init(dictionaryLiteral elements:(Unidoc.Scalar, Never)...)
    {
        self.init(table: [:])
    }
}
extension ProtocolConformances<Int>
{
    init(of subject:Unidoc.Scalar,
        signatures:borrowing [DynamicLinker.ExtensionSignature],
        extensions:borrowing [SymbolGraph.Extension],
        modules:borrowing [SymbolGraph.ModuleContext],
        context:inout DynamicLinker)
    {
        self = [:]

        for (`extension`, signature):(SymbolGraph.Extension, DynamicLinker.ExtensionSignature)
            in zip(extensions, signatures)
        {
            let module:SymbolGraph.ModuleContext = modules[`extension`.culture]
            for p:Int32 in `extension`.conformances
            {
                //  Only track conformances that were declared by modules in
                //  the current package.
                if  let p:Unidoc.Scalar = context.current.scalars.decls[p],
                    case false = module.already(conforms: subject, to: p)
                {
                    self[to: p].append(.init(
                        conditions: signature.conditions,
                        culture: `extension`.culture))
                }
            }
        }

        for i:Dictionary<Unidoc.Scalar, [ProtocolConformance<Int>]>.Index in self.table.indices
        {
            let `protocol`:Unidoc.Scalar = self.table.keys[i]
            context.simplify(conformances: &self.table.values[i],
                of: subject,
                to: `protocol`)
        }
    }
}

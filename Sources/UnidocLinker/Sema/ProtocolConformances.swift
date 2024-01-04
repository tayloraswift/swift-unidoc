import Signatures
import SymbolGraphs
import Unidoc
import UnidocDiagnostics

/// Describes a single type’s protocol conformances. Depending on how this structure is being
/// used, the lists may or may not be exhaustive.
struct ProtocolConformances:Sendable
{
    private
    var table:[Unidoc.Scalar: [Unidoc.Linker.ExtensionConditions]]

    private
    init(table:[Unidoc.Scalar: [Unidoc.Linker.ExtensionConditions]])
    {
        self.table = table
    }
}
extension ProtocolConformances
{
    /// Yields all known conformances to the specified protocol. This subscript returns an empty
    /// list if no conformances are known to exist. It can also return more than one conformance
    /// if multiple modules declare conformances to the same protocol.
    subscript(to protocol:Unidoc.Scalar) -> [Unidoc.Linker.ExtensionConditions]
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
    func makeIterator()
        -> Dictionary<Unidoc.Scalar, [Unidoc.Linker.ExtensionConditions]>.Iterator
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
extension ProtocolConformances
{
    init(of subject:Unidoc.Scalar,
        conditions:borrowing [Unidoc.Linker.ExtensionConditions],
        extensions:borrowing [SymbolGraph.Extension],
        modules:borrowing [SymbolGraph.ModuleContext],
        context:inout Unidoc.Linker)
    {
        self = [:]

        for (conditions, `extension`):
            (Unidoc.Linker.ExtensionConditions, SymbolGraph.Extension) in zip(
            conditions,
            extensions)
        {
            let module:SymbolGraph.ModuleContext = modules[conditions.culture]
            for p:Int32 in `extension`.conformances
            {
                //  Only track conformances that were declared by modules in
                //  the current package.
                if  let p:Unidoc.Scalar = context.current.scalars.decls[p],
                    case false = module.already(conforms: subject, to: p)
                {
                    self[to: p].append(conditions)
                }
            }
        }

        for i:Dictionary<Unidoc.Scalar, [Unidoc.Linker.ExtensionConditions]>.Index
            in self.table.indices
        {
            let `protocol`:Unidoc.Scalar = self.table.keys[i]
            context.simplify(conformances: &self.table.values[i],
                of: subject,
                to: `protocol`)
        }
    }
}

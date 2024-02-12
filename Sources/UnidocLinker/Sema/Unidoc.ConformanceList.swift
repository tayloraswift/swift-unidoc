import Signatures
import SymbolGraphs
import Unidoc
import SourceDiagnostics

extension Unidoc
{
    /// Describes a single type’s protocol conformances. Depending on how this structure is
    /// being used, the lists may or may not be exhaustive.
    struct ConformanceList:Sendable
    {
        private
        var table:[Scalar: [ExtensionConditions]]

        private
        init(table:[Scalar: [ExtensionConditions]])
        {
            self.table = table
        }
    }
}
extension Unidoc.ConformanceList
{
    /// Yields all known conformances to the specified protocol. This subscript returns an empty
    /// list if no conformances are known to exist. It can also return more than one conformance
    /// if multiple modules declare conformances to the same protocol.
    subscript(to protocol:Unidoc.Scalar) -> [Unidoc.ExtensionConditions]
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
extension Unidoc.ConformanceList:Sequence
{
    func makeIterator()
        -> Dictionary<Unidoc.Scalar, [Unidoc.ExtensionConditions]>.Iterator
    {
        self.table.makeIterator()
    }
}
extension Unidoc.ConformanceList:ExpressibleByDictionaryLiteral
{
    init(dictionaryLiteral elements:(Unidoc.Scalar, Never)...)
    {
        self.init(table: [:])
    }
}
extension Unidoc.ConformanceList
{
    init(of subject:Unidoc.Scalar,
        conditions:borrowing [Unidoc.ExtensionConditions],
        extensions:borrowing [SymbolGraph.Extension],
        modules:borrowing [SymbolGraph.ModuleContext],
        context:inout Unidoc.Linker)
    {
        self = [:]

        for (conditions, `extension`):
            (Unidoc.ExtensionConditions, SymbolGraph.Extension) in zip(
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

        for i:Dictionary<Unidoc.Scalar, [Unidoc.ExtensionConditions]>.Index
            in self.table.indices
        {
            let `protocol`:Unidoc.Scalar = self.table.keys[i]
            context.simplify(conformances: &self.table.values[i],
                of: subject,
                to: `protocol`)
        }
    }
}

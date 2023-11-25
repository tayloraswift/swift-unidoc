import CodelinkResolution
import SymbolGraphs
import Symbols
import Unidoc
import UnidocDiagnostics

extension DiagnosticContext<DynamicSymbolicator>
{
    private mutating
    func resolving<Success>(
        codelinks:CodelinkResolver<Unidoc.Scalar>,
        context:DynamicContext,
        with body:(inout DynamicResolver) throws -> Success) rethrows -> Success
    {
        var resolver:DynamicResolver = .init(
            diagnostics: consume self,
            codelinks: codelinks,
            context: context)

        defer
        {
            self = resolver.diagnostics
        }

        return try body(&resolver)
    }

    mutating
    func resolving<Success>(
        namespace:Symbol.Module,
        module:SymbolGraph.ModuleContext,
        global:DynamicContext,
        scope:[String] = [],
        with body:(inout DynamicResolver) throws -> Success) rethrows -> Success
    {
        try self.resolving(
            codelinks: .init(table: module.codelinks, scope: .init(
                namespace: namespace,
                imports: module.imports,
                path: scope)),
            context: global,
            with: body)
    }
}

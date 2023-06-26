import ModuleGraphs
import SymbolGraphs
import Symbols

final
class SnapshotObject:Sendable
{
    /// Maps nested declarations to scopes. Scopes might be non-local.
    private
    let hierarchy:[Int32: Scalar96]

    let declarations:SymbolGraph.Table<Scalar96?>
    let namespaces:[Scalar96?]

    let snapshot:Snapshot

    private
    init(hierarchy:[Int32: Scalar96],
        declarations:SymbolGraph.Table<Scalar96?>,
        namespaces:[Scalar96?],
        snapshot:Snapshot)
    {
        self.hierarchy = hierarchy
            self.declarations = declarations
            self.namespaces = namespaces
            self.snapshot = snapshot
    }
}
extension SnapshotObject
{
    var translator:Snapshot.Translator { self.snapshot.translator }
    var graph:SymbolGraph { self.snapshot.graph }

    var files:Snapshot.View<FileSymbol> { .init(self.snapshot) }
    var symbols:Snapshot.View<ScalarSymbol> { .init(self.snapshot) }
    var nodes:Snapshot.View<SymbolGraph.Node> { .init(self.snapshot) }
}
extension SnapshotObject
{
    convenience
    init(snapshot:__owned Snapshot, upstream:__shared UpstreamScalars)
    {
        let translator:Snapshot.Translator = snapshot.translator

        let declarations:SymbolGraph.Table<Scalar96?> = snapshot.graph.link
        {
            translator[citizen: $0]
        }
        dynamic:
        {
            upstream.citizens[$0]
        }

        let namespaces:[Scalar96?] = snapshot.graph.namespaces.map
        {
            upstream.cultures[$0]
        }

        var hierarchy:[Int32: Scalar96] = [:]
            hierarchy.reserveCapacity(snapshot.graph.nodes.count)

        for (n, node):(Int32, SymbolGraph.Node) in zip(
            snapshot.graph.nodes.indices,
            snapshot.graph.nodes)
        {
            for `extension`:SymbolGraph.Extension in node.extensions
            {
                for nested:Int32 in `extension`.nested where
                    snapshot.graph.citizens.contains(nested)
                {
                    hierarchy[nested] = declarations[n]
                }
            }
        }

        self.init(hierarchy: hierarchy,
            declarations: declarations,
            namespaces: namespaces,
            snapshot: snapshot)
    }
}
extension SnapshotObject
{
    func scope(of declaration:Scalar96) -> Scalar96?
    {
        self.translator[scalar: declaration].map(self.scope(of:)) ?? nil
    }
    func scope(of declaration:Int32) -> Scalar96?
    {
        self.hierarchy[declaration]
    }
}
extension SnapshotObject
{
    func project(extension:SymbolGraph.Extension, of scope:Scalar96) -> ExtensionProjection
    {
        .init(conditions: `extension`.conditions.map
            {
                $0.map { self.declarations[$0] }
            },
            culture: self.translator[culture: `extension`.culture],
            scope: scope,
            conformances: `extension`.conformances.compactMap
            {
                self.declarations[$0]
            },
            features: `extension`.features.compactMap
            {
                self.declarations[$0]
            },
            nested: `extension`.nested.compactMap
            {
                self.declarations[$0]
            })
    }
}

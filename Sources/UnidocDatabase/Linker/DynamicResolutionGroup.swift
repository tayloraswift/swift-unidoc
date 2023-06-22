import CodelinkResolution
import ModuleGraphs
import SymbolGraphs

final
class DynamicResolutionGroup:Sendable
{
    let codelinks:CodelinkResolver<GlobalAddress>.Table
    let imports:[ModuleIdentifier]

    init(codelinks:CodelinkResolver<GlobalAddress>.Table, imports:[ModuleIdentifier])
    {
        self.codelinks = codelinks
        self.imports = imports
    }
}
extension DynamicResolutionGroup
{
    func link(article:SymbolGraph.Article<some Any>,
        namespace:ModuleIdentifier,
        scope:[String])
    {
        //  TODO: create this lazily
        let _:CodelinkResolver<GlobalAddress> = .init(table: self.codelinks,
            scope: .init(namespace: namespace, imports: self.imports, path: scope))
        let _:[Void] = article.referents.map
        {
            switch $0
            {
            case .scalar, .vector:
                return

            case .unresolved(_):
                return
            }
        }
    }
}

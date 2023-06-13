import SymbolGraphs
import Symbols

struct LocalProjector
{
    let translator:DynamicObject.Translator

    private
    let scalars:SymbolGraph.Table<GlobalAddress?>
    private
    let modules:[GlobalAddress?]

    private
    init(translator:DynamicObject.Translator,
        scalars:SymbolGraph.Table<GlobalAddress?>,
        modules:[GlobalAddress?])
    {
        self.translator = translator
        self.scalars = scalars
        self.modules = modules
    }
}
extension LocalProjector
{
    init(translator:__owned DynamicObject.Translator,
        upstream:__shared UpstreamSymbols,
        graph:__shared SymbolGraph)
    {
        self.init(translator: translator,
            scalars: graph.link
            {
                translator[scalar: $0]
            }
            dynamic:
            {
                upstream.scalars[$0]
            },
            modules: graph.namespaces.map
            {
                upstream.modules[$0]
            })
    }
    init(policies:__shared DocumentationDatabase.Policies,
        upstream:__shared UpstreamSymbols,
        receipt:__shared DocumentationDatabase.ObjectReceipt,
        graph:__shared SymbolGraph) throws
    {
        self.init(translator: try .init(policies: policies,
                package: receipt.package,
                version: receipt.version,
                graph: graph),
            upstream: upstream,
            graph: graph)
    }
}
extension LocalProjector
{
    static
    func * (scalar:Int32, self:Self) -> GlobalAddress?
    {
        self.scalars[scalar] ?? nil
    }
    static
    func / (address:GlobalAddress, self:Self) -> Int32?
    {
        self.translator[address].scalar
    }
}
extension LocalProjector
{
    static
    func * (module:Int, self:Self) -> GlobalAddress?
    {
        self.modules[module] ?? nil
    }
    static
    func / (address:GlobalAddress, self:Self) -> Int?
    {
        self.translator[address].culture
    }
}

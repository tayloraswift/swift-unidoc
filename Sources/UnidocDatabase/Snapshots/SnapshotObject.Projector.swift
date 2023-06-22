import SymbolGraphs

extension SnapshotObject
{
    struct Projector
    {
        let snapshot:Snapshot

        private
        let scalars:SymbolGraph.Table<GlobalAddress?>
        private
        let modules:[GlobalAddress?]

        private
        init(snapshot:Snapshot,
            scalars:SymbolGraph.Table<GlobalAddress?>,
            modules:[GlobalAddress?])
        {
            self.snapshot = snapshot
            self.scalars = scalars
            self.modules = modules
        }
    }
}
extension SnapshotObject.Projector
{
    var graph:SymbolGraph { self.snapshot.graph }
}
extension SnapshotObject.Projector
{
    init(snapshot:__owned Snapshot, upstream:__shared UpstreamSymbols)
    {
        let translator:Snapshot.Translator = snapshot.translator

        let scalars:SymbolGraph.Table<GlobalAddress?> = snapshot.graph.link
        {
            translator[address: $0]
        }
        dynamic:
        {
            upstream.scalars[$0]
        }
        let modules:[GlobalAddress?] = snapshot.graph.namespaces.map
        {
            upstream.modules[$0]
        }
        self.init(snapshot: snapshot, scalars: scalars, modules: modules)
    }
}
extension SnapshotObject.Projector
{
    static
    func * (scalar:Int32, self:Self) -> GlobalAddress?
    {
        self.scalars[scalar] ?? nil
    }
    static
    func * (module:Int, self:Self) -> GlobalAddress?
    {
        self.modules[module] ?? nil
    }
}
extension SnapshotObject.Projector
{
    static
    func / (global:GlobalAddress, self:Self) -> Int32?
    {
        self.snapshot.translator.contains(global) ? global.address : nil
    }
    static
    func / (global:GlobalAddress, self:Self) -> Int?
    {
        self.snapshot.translator.contains(global) ? global.culture : nil
    }
}

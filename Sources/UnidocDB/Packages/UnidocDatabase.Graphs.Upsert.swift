extension UnidocDatabase.Graphs
{
    @frozen public
    enum Upsert:Equatable, Sendable
    {
        case insert
        case update
    }
}

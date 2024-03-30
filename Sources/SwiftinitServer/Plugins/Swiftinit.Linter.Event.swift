import HTML

extension Swiftinit.Linter
{
    enum Event
    {
        case lintedBuilds(Int)
        case caught(any Error)
    }
}
extension Swiftinit.Linter.Event:Unidoc.CollectionEvent
{
}
extension Swiftinit.Linter.Event:HTML.OutputStreamable
{
    static
    func += (div:inout HTML.ContentEncoder, self:Self)
    {
        switch self
        {
        case .lintedBuilds(let builds):
            div[.h3] = "Linted builds"
            div[.p] = builds == 1 ? "Linted 1 build." : "Linted \(builds) builds."

        case .caught(let error):
            div[.h3] = "Caught error"
            div[.pre] = String.init(reflecting: error)
        }
    }
}

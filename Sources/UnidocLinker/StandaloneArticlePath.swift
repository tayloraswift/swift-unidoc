import ModuleGraphs

struct StandaloneArticlePath:Equatable, Hashable, Sendable
{
    private
    let string:String

    private
    init(string:String)
    {
        self.string = string
    }
}
extension StandaloneArticlePath
{
    static
    func join(_ components:some Sequence<String>) -> Self
    {
        .init(string: components.joined(separator: "/"))
    }
}

import UnidocRecords

extension Unidoc.Linker
{
    struct TreeMembers
    {
        var articles:[Unidoc.Noun]
        var procs:[Unidoc.Shoot]
        var types:[Unidoc.Shoot: Unidoc.Citizenship]

        private
        init(articles:[Unidoc.Noun],
            procs:[Unidoc.Shoot],
            types:[Unidoc.Shoot: Unidoc.Citizenship])
        {
            self.articles = articles
            self.procs = procs
            self.types = types
        }
    }
}
extension Unidoc.Linker.TreeMembers:ExpressibleByArrayLiteral
{
    init(arrayLiteral:Never...)
    {
        self.init(articles: [], procs: [], types: [:])
    }
}
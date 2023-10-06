import UnidocRecords

extension DynamicLinker
{
    struct TreeMembers
    {
        var articles:[Volume.Noun]
        var procs:[Volume.Shoot]
        var types:[Volume.Shoot: Volume.Citizenship]

        private
        init(articles:[Volume.Noun],
            procs:[Volume.Shoot],
            types:[Volume.Shoot: Volume.Citizenship])
        {
            self.articles = articles
            self.procs = procs
            self.types = types
        }
    }
}
extension DynamicLinker.TreeMembers:ExpressibleByArrayLiteral
{
    init(arrayLiteral:Never...)
    {
        self.init(articles: [], procs: [], types: [:])
    }
}

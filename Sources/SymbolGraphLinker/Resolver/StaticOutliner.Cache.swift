import MarkdownAST
import SymbolGraphs

extension StaticOutliner
{
    /// This is keyed by ``Markdown.SourceString`` and not just ``String`` because link
    /// resolution varies depending on its location.
    struct Cache
    {
        private
        var references:[Markdown.SourceString: Int]
        private
        var outlines:[SymbolGraph.Outline]

        init()
        {
            self.references = [:]
            self.outlines = []
        }
    }
}
extension StaticOutliner.Cache
{
    var fold:Int { self.outlines.endIndex }

    mutating
    func clear() -> [SymbolGraph.Outline]
    {
        defer { self = .init() }
        return self.outlines
    }

    mutating
    func callAsFunction(_ key:Markdown.SourceString,
        with populate:() throws -> SymbolGraph.Outline?) rethrows -> Int?
    {
        try
        {
            if  let reference:Int = $0
            {
                return reference
            }
            else if let outline:SymbolGraph.Outline = try populate()
            {
                let next:Int = self.outlines.endIndex
                self.outlines.append(outline)
                $0 = next
                return next
            }
            else
            {
                return nil
            }
        } (&self.references[key])
    }
}

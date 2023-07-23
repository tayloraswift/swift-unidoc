import SymbolGraphs

extension StaticOutliner
{
    struct Cache
    {
        private
        var references:[String: Int]
        private(set)
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
    mutating
    func callAsFunction(_ key:String,
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

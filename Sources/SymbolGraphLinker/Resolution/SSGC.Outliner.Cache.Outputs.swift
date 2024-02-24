import SymbolGraphs

extension SSGC.Outliner.Cache
{
    struct Outputs
    {
        private(set)
        var outlines:[SymbolGraph.Outline]
        private
        var indices:[SymbolGraph.Outline: Int]

        init()
        {
            self.outlines = []
            self.indices = [:]
        }
    }
}
extension SSGC.Outliner.Cache.Outputs
{
    mutating
    func add(outline:SymbolGraph.Outline) -> Int
    {
        {
            if  let index:Int = $0
            {
                return index
            }
            else
            {
                let next:Int = self.outlines.endIndex
                self.outlines.append(outline)
                $0 = next
                return next
            }
        } (&self.indices[outline])
    }
}

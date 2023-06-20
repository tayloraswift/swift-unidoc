import SymbolGraphs

extension StaticOutliner
{
    struct Cache
    {
        private
        var references:[String: UInt32]
        private(set)
        var referents:[SymbolGraph.Referent]

        init()
        {
            self.references = [:]
            self.referents = []
        }
    }
}
extension StaticOutliner.Cache
{
    mutating
    func callAsFunction(_ key:String,
        with populate:() throws -> SymbolGraph.Referent?) rethrows -> UInt32?
    {
        try
        {
            if  let reference:UInt32 = $0
            {
                return reference
            }
            else if let referent:SymbolGraph.Referent = try populate()
            {
                let next:UInt32 = .init(self.referents.endIndex)
                self.referents.append(referent)
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
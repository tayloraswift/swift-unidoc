extension Unidoc.LinkerTables
{
    struct Counter
    {
        private
        var index:Int

        init()
        {
            self.index = 0
        }
    }
}
extension Unidoc.LinkerTables.Counter
{
    mutating
    func callAsFunction() -> Int
    {
        defer { self.index += 1 }
        return  self.index
    }
}

extension Unidoc.Linker.Tables
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
extension Unidoc.Linker.Tables.Counter
{
    mutating
    func callAsFunction() -> Int
    {
        defer { self.index += 1 }
        return  self.index
    }
}

import HTML

extension Pie
{
    @frozen public
    struct Legend
    {
        public
        let sectors:[Sector]
        public
        let total:Int

        @inlinable public
        init(sectors:[Sector], total:Int)
        {
            self.sectors = sectors
            self.total = total
        }
    }
}
extension Pie.Legend:HyperTextOutputStreamable
{
    public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        let divisor:Double = .init(self.total)
        for sector:Sector in self.sectors
        {
            sector.legend(&html, share: Double.init(sector.value) / divisor)
        }
    }
}

import UnidocRecords

extension Volume.Metadata
{
    var title:String
    {
        self.display ?? "\(self.symbol.package)"
    }
}

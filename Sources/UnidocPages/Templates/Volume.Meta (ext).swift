import UnidocRecords

extension Volume.Meta
{
    var domain:Domain { .init(self) }

    var title:String
    {
        self.display ?? "\(self.symbol.package)"
    }
}

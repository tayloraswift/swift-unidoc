import UnidocRecords

extension Unidoc.VolumeMetadata
{
    var title:String
    {
        self.display ?? "\(self.symbol.package)"
    }
}

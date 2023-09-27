import UnidocRecords

extension Volume.Meta
{
    var title:String
    {
        "\(self.display ?? "\(self.package)") Documentation"
    }
}

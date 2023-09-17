import UnidocRecords

extension Volume.Names
{
    var title:String
    {
        "\(self.display ?? "\(self.package)") Documentation"
    }
}

import UnidocRecords

extension Record.Zone
{
    var title:String
    {
        "\(self.display ?? "\(self.package)") Documentation"
    }
}

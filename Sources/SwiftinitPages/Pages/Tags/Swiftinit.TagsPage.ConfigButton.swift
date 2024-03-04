import HTML

extension Swiftinit.TagsPage
{
    struct ConfigButton
    {
        let package:Unidoc.Package
        let update:String
        let value:String
        let label:String

        init(package:Unidoc.Package, update:String, value:String, label:String)
        {
            self.package = package
            self.update = update
            self.value = value
            self.label = label
        }
    }
}
extension Swiftinit.TagsPage.ConfigButton:HTML.OutputStreamable
{
    static
    func += (form:inout HTML.ContentEncoder, self:Self)
    {
        form[.input]
        {
            $0.type = "hidden"
            $0.name = "package"
            $0.value = "\(self.package)"
        }
        form[.input]
        {
            $0.type = "hidden"
            $0.name = self.update
            $0.value = self.value
        }

        form[.button] { $0.type = "submit" } = self.label
    }
}

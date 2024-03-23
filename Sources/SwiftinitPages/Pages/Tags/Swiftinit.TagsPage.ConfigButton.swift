import HTML

extension Swiftinit.TagsPage
{
    struct ConfigButton
    {
        let package:Unidoc.Package
        let update:String
        let value:String
        let label:String
        let area:Bool

        init(package:Unidoc.Package,
            update:String,
            value:String,
            label:String,
            area:Bool = true)
        {
            self.package = package
            self.update = update
            self.value = value
            self.label = label
            self.area = area
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

        form[.button]
        {
            $0.class = self.area ? "area" : "text"
            $0.type = "submit"
        } = self.label
    }
}

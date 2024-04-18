import HTML
import URI

extension Unidoc.TagsPage
{
    struct ConfigButton
    {
        let package:Unidoc.Package
        let update:String
        let value:String
        let label:String
        let from:URI?
        let area:Bool

        init(package:Unidoc.Package,
            update:String,
            value:String,
            label:String,
            from:URI? = nil,
            area:Bool = true)
        {
            self.package = package
            self.update = update
            self.value = value
            self.label = label
            self.from = from
            self.area = area
        }
    }
}
extension Unidoc.TagsPage.ConfigButton:HTML.OutputStreamable
{
    static
    func += (form:inout HTML.ContentEncoder, self:Self)
    {
        if  let from:URI = self.from
        {
            form[.input]
            {
                $0.type = "hidden"
                $0.name = "from"
                $0.value = "\(from)"
            }
        }

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

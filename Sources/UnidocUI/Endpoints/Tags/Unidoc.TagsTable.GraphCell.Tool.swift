import HTML
import Symbols

extension Unidoc.TagsTable.GraphCell
{
    struct Tool
    {
        let edition:Unidoc.Edition
        let package:Symbol.Package
        let label:String

        init(edition:Unidoc.Edition, package:Symbol.Package, label:String)
        {
            self.edition = edition
            self.package = package
            self.label = label
        }
    }
}
extension Unidoc.TagsTable.GraphCell.Tool:HTML.OutputStreamable
{
    static
    func += (form:inout HTML.ContentEncoder, self:Self)
    {
        form[.input]
        {
            $0.type = "hidden"
            $0.name = "package"
            $0.value = "\(self.edition.package)"
        }
        form[.input]
        {
            $0.type = "hidden"
            $0.name = "version"
            $0.value = "\(self.edition.version)"
        }
        form[.input]
        {
            $0.type = "hidden"
            $0.name = "from"
            $0.value = "\(Unidoc.TagsEndpoint[self.package])"
        }

        form[.button] { $0.type = "submit" } = self.label
    }
}

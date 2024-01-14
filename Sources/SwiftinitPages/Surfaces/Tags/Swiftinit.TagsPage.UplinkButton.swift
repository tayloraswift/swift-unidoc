import HTML
import Symbols

extension Swiftinit.TagsPage
{
    struct UplinkButton
    {
        let edition:Unidoc.Edition
        let package:Symbol.Package

        init(edition:Unidoc.Edition, package:Symbol.Package)
        {
            self.edition = edition
            self.package = package
        }
    }
}
extension Swiftinit.TagsPage.UplinkButton:HTML.OutputStreamable
{
    static
    func += (form:inout HTML.ContentEncoder, self:Self)
    {
        form[.p]
        {
            $0[.input]
            {
                $0.type = "hidden"
                $0.name = "package"
                $0.value = "\(self.edition.package)"
            }
            $0[.input]
            {
                $0.type = "hidden"
                $0.name = "version"
                $0.value = "\(self.edition.version)"
            }
            $0[.input]
            {
                $0.type = "hidden"
                $0.name = "redirect"
                $0.value = "\(Swiftinit.Tags[self.package])"
            }
        }
        form[.p]
        {
            $0[.button] { $0.type = "submit" } = "Uplink"
        }
    }
}

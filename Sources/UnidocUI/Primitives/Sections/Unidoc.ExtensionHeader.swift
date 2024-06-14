import HTML
import Symbols

extension Unidoc
{
    struct ExtensionHeader:Identifiable
    {
        private
        let heading:ExtensionHeading
        private
        let culture:Unidoc.LinkReference<Unidoc.CultureVertex>
        private
        let `where`:Unidoc.WhereClause?

        let id:String

        init(
            heading:ExtensionHeading,
            culture:Unidoc.LinkReference<Unidoc.CultureVertex>,
            where clause:Unidoc.WhereClause?,
            id:String)
        {
            self.heading = heading
            self.culture = culture
            self.where = clause
            self.id = id
        }
    }
}
extension Unidoc.ExtensionHeader:HTML.OutputStreamableAnchor
{
    static
    func += (header:inout HTML.ContentEncoder, self:Self)
    {
        header[.h2]
        {
            let name:String

            switch self.heading
            {
            case .citizens:     name = "Citizens"
            case .available:    name = "Available"
            case .extension:    name = "Extension"
            }

            $0[.a] { $0.href = "#\(self.id)" } = name
            $0 += " in "
            $0[.a] { $0.href = self.culture.target?.url } = "\(self.culture.vertex.module.id)"
        }

        header[.div, .code] { $0.class = "constraints" } = self.where
    }
}

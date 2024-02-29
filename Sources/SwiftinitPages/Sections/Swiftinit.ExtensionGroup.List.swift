import HTML
import Unidoc

extension Swiftinit.ExtensionGroup
{
    struct List
    {
        let heading:String
        let items:Items

        init(heading:String, items:Items)
        {
            self.heading = heading
            self.items = items
        }
    }
}
extension Swiftinit.ExtensionGroup.List:HTML.OutputStreamable
{
    static
    func += (section:inout HTML.ContentEncoder, self:Self)
    {
        section[.h3] = self.heading

        if !self.items.visible.isEmpty
        {
            section[.ul]
            {
                for card:Swiftinit.DeclCard in self.items.visible
                {
                    $0[.li] = card
                }
            }
        }

        if  self.items.details.isEmpty
        {
            return
        }

        section[.details]
        {
            $0[.summary]
            {
                $0[.p] { $0.class = "view" } = """
                Show implementation details (\(self.items.details.count))
                """

                $0[.p] { $0.class = "hide" } = """
                Hide implementation details
                """
            }

            $0[.ul]
            {
                for card:Swiftinit.DeclCard in self.items.details
                {
                    $0[.li] = card
                }
            }
        }
    }
}

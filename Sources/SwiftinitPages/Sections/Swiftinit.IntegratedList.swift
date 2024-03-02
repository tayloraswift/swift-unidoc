import HTML

extension Swiftinit
{
    struct IntegratedList
    {
        private
        let context:IdentifiablePageContext<Swiftinit.Vertices>
        let items:[Unidoc.Scalar]

        private
        init(context:IdentifiablePageContext<Swiftinit.Vertices>, items:[Unidoc.Scalar])
        {
            self.context = context
            self.items = items
        }
    }
}
extension Swiftinit.IntegratedList
{
    init?(_ context:IdentifiablePageContext<Swiftinit.Vertices>,
        items:[Unidoc.Scalar])
    {
        if  items.isEmpty
        {
            return nil
        }

        self.init(context: context, items: items)
    }
}
extension Swiftinit.IntegratedList:HTML.OutputStreamable
{
    static
    func += (section:inout HTML.ContentEncoder, self:Self)
    {
        section[.ul]
        {
            for item:Unidoc.Scalar in self.items
            {
                $0[.li] = self.context.card(item)
            }
        }
    }
}

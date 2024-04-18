import HTML

extension Unidoc
{
    struct SegregatedList
    {
        private(set)
        var visible:[Unidoc.DeclCard]
        private
        var details:[Unidoc.DeclCard]

        private
        init(visible:[Unidoc.DeclCard], details:[Unidoc.DeclCard])
        {
            self.visible = visible
            self.details = details
        }
    }
}
extension Unidoc.SegregatedList:ExpressibleByArrayLiteral
{
    init(arrayLiteral:Never...) { self.init(visible: [], details: []) }
}
extension Unidoc.SegregatedList
{
    init?(_ context:borrowing Unidoc.RelativePageContext,
        group:__shared [Unidoc.Scalar])
    {
        if  group.isEmpty
        {
            return nil
        }

        self = .partition(group, with: context)
    }

    static
    func partition(_ items:[Unidoc.Scalar],
        with context:Unidoc.RelativePageContext) -> Self
    {
        items.reduce(into: []) { $0.append(context.card(decl: $1)) }
    }
}
extension Unidoc.SegregatedList:Unidoc.CollapsibleContent
{
    var length:Int { self.visible.count }
    var count:Int { self.visible.count + self.details.count }
}
extension Unidoc.SegregatedList
{
    var isEmpty:Bool { self.visible.isEmpty && self.details.isEmpty }

    mutating
    func append(_ card:Unidoc.DeclCard?)
    {
        card.map { self.append($0) }
    }

    mutating
    func append(_ card:Unidoc.DeclCard)
    {
        card.vertex.flags.route.underscored
        ? self.details.append(card)
        : self.visible.append(card)
    }
}
extension Unidoc.SegregatedList:HTML.OutputStreamable
{
    static
    func += (section:inout HTML.ContentEncoder, self:Self)
    {
        if !self.visible.isEmpty
        {
            section[.ul, { $0.class = "cards" }]
            {
                for card:Unidoc.DeclCard in self.visible
                {
                    $0[.li] = card
                }
            }
        }

        if  self.details.isEmpty
        {
            return
        }

        section[.details, { $0.class = "impl" }]
        {
            $0[.summary]
            {
                $0[.p] { $0.class = "view" } = """
                Show implementation details (\(self.details.count))
                """

                $0[.p] { $0.class = "hide" } = """
                Hide implementation details
                """
            }

            $0[.ul, { $0.class = "cards" }]
            {
                for card:Unidoc.DeclCard in self.details
                {
                    $0[.li] = card
                }
            }
        }
    }
}

import HTML

extension Swiftinit
{
    struct SegregatedList
    {
        private(set)
        var visible:[Swiftinit.DeclCard]
        private
        var details:[Swiftinit.DeclCard]

        private
        init(visible:[Swiftinit.DeclCard], details:[Swiftinit.DeclCard])
        {
            self.visible = visible
            self.details = details
        }
    }
}
extension Swiftinit.SegregatedList:ExpressibleByArrayLiteral
{
    init(arrayLiteral:Never...) { self.init(visible: [], details: []) }
}
extension Swiftinit.SegregatedList
{
    init?(_ context:borrowing IdentifiablePageContext<Swiftinit.Vertices>,
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
        with context:IdentifiablePageContext<Swiftinit.Vertices>) -> Self
    {
        items.reduce(into: []) { $0.append(context.card(decl: $1)) }
    }
}
extension Swiftinit.SegregatedList:Swiftinit.CollapsibleContent
{
    var length:Int { self.visible.count }
    var count:Int { self.visible.count + self.details.count }
}
extension Swiftinit.SegregatedList
{
    var isEmpty:Bool { self.visible.isEmpty && self.details.isEmpty }

    mutating
    func append(_ card:Swiftinit.DeclCard?)
    {
        card.map { self.append($0) }
    }

    mutating
    func append(_ card:Swiftinit.DeclCard)
    {
        card.vertex.flags.route.underscored
        ? self.details.append(card)
        : self.visible.append(card)
    }
}
extension Swiftinit.SegregatedList:HTML.OutputStreamable
{
    static
    func += (section:inout HTML.ContentEncoder, self:Self)
    {
        if !self.visible.isEmpty
        {
            section[.ul, { $0.class = "cards" }]
            {
                for card:Swiftinit.DeclCard in self.visible
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
                for card:Swiftinit.DeclCard in self.details
                {
                    $0[.li] = card
                }
            }
        }
    }
}

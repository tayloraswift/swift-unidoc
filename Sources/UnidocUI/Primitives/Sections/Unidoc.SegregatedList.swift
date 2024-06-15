import HTML

extension Unidoc
{
    struct SegregatedList
    {
        private(set)
        var recommended:[Unidoc.DeclCard]
        private
        var discouraged:[Unidoc.DeclCard]
        private
        var underscored:[Unidoc.DeclCard]
        private
        var interfaces:[Unidoc.DeclCard]

        private
        init(
            recommended:[Unidoc.DeclCard],
            discouraged:[Unidoc.DeclCard],
            underscored:[Unidoc.DeclCard],
            interfaces:[Unidoc.DeclCard])
        {
            self.recommended = recommended
            self.discouraged = discouraged
            self.underscored = underscored
            self.interfaces = interfaces
        }
    }
}
extension Unidoc.SegregatedList:ExpressibleByArrayLiteral
{
    init(arrayLiteral:Never...)
    {
        self.init(recommended: [], discouraged: [], underscored: [], interfaces: [])
    }
}
extension Unidoc.SegregatedList
{
    init?(group:__shared [Unidoc.Scalar], with context:borrowing Unidoc.InternalPageContext)
    {
        if  group.isEmpty
        {
            return nil
        }

        self = .partition(group, with: context)
    }

    static
    func partition(_ items:[Unidoc.Scalar],
        with context:Unidoc.InternalPageContext) -> Self
    {
        items.reduce(into: []) { $0.append(context.card(decl: $1)) }
    }
}
extension Unidoc.SegregatedList:Unidoc.CollapsibleContent
{
    var length:Int { self.recommended.count }
    var count:Int
    {
        self.recommended.count +
        self.discouraged.count +
        self.underscored.count +
        self.interfaces.count
    }
}
extension Unidoc.SegregatedList
{
    var isEmpty:Bool
    {
        self.recommended.isEmpty &&
        self.discouraged.isEmpty &&
        self.underscored.isEmpty &&
        self.interfaces.isEmpty
    }

    mutating
    func append(_ card:Unidoc.DeclCard?)
    {
        card.map { self.append($0) }
    }

    mutating
    func append(_ card:Unidoc.DeclCard)
    {
        guard case nil = card.vertex.signature.spis
        else
        {
            self.interfaces.append(card)
            return
        }
        guard card.vertex.signature.availability.isGenerallyRecommended
        else
        {
            self.discouraged.append(card)
            return
        }

        if  card.vertex.flags.route.underscored
        {
            self.underscored.append(card)
        }
        else
        {
            self.recommended.append(card)
        }
    }
}
extension Unidoc.SegregatedList:HTML.OutputStreamable
{
    static
    func += (section:inout HTML.ContentEncoder, self:Self)
    {
        if !self.recommended.isEmpty
        {
            section[.ul, { $0.class = "cards" }]
            {
                for card:Unidoc.DeclCard in self.recommended
                {
                    $0[.li] = card
                }
            }
        }

        if !self.underscored.isEmpty
        {
            section[.details, { $0.class = "impl" }]
            {
                $0[.summary]
                {
                    $0[.p] { $0.class = "view" } = """
                    Show implementation details (\(self.underscored.count))
                    """

                    $0[.p] { $0.class = "hide" } = """
                    Hide implementation details
                    """
                }

                $0[.ul, { $0.class = "cards" }]
                {
                    for card:Unidoc.DeclCard in self.underscored
                    {
                        $0[.li] = card
                    }
                }
            }
        }

        if !self.discouraged.isEmpty
        {
            section[.details, { $0.class = "impl" }]
            {
                $0[.summary]
                {
                    $0[.p] { $0.class = "view" } = """
                    Show obsolete interfaces (\(self.discouraged.count))
                    """

                    $0[.p] { $0.class = "hide" } = """
                    Hide obsolete interfaces
                    """
                }

                $0[.ul, { $0.class = "cards" }]
                {
                    for card:Unidoc.DeclCard in self.discouraged
                    {
                        $0[.li] = card
                    }
                }
            }
        }

        if !self.interfaces.isEmpty
        {
            section[.details, { $0.class = "impl" }]
            {
                $0[.summary]
                {
                    $0[.p] { $0.class = "view" } = """
                    Show system interfaces (\(self.interfaces.count))
                    """

                    $0[.p] { $0.class = "hide" } = """
                    Hide system interfaces
                    """
                }

                $0[.ul, { $0.class = "cards spi" }]
                {
                    for card:Unidoc.DeclCard in self.interfaces
                    {
                        $0[.li] = card
                    }
                }
            }
        }
    }
}

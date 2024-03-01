import HTML

extension Swiftinit
{
    struct Topic
    {
        private
        let context:IdentifiablePageContext<Swiftinit.Vertices>
        let caption:Unidoc.Passage?
        let members:[Unidoc.TopicMember]

        init(_ context:IdentifiablePageContext<Swiftinit.Vertices>,
            caption:Unidoc.Passage? = nil,
            members:[Unidoc.TopicMember])
        {
            self.context = context
            self.caption = caption
            self.members = members
        }
    }
}
extension Swiftinit.Topic:HTML.OutputStreamable
{
    static
    func += (section:inout HTML.ContentEncoder, self:Self)
    {
        section ?= self.caption.map { ProseSection.init(self.context, passage: $0) }

        section[.ul]
        {
            for member:Unidoc.TopicMember in self.members
            {
                switch member
                {
                case .scalar(let scalar):
                    $0[.li] = self.context.card(scalar)

                case .text(let text):
                    $0[.li] { $0[.span] { $0[.code] = text } }
                }
            }
        }
    }
}

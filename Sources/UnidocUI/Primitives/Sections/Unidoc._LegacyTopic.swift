import HTML
import MarkdownABI

extension Unidoc
{
    struct _LegacyTopic
    {
        private
        let context:Unidoc.InternalPageContext
        private
        let caption:Unidoc.Passage?
        private
        let members:[Unidoc.TopicMember]

        init(_ context:Unidoc.InternalPageContext,
            caption:Unidoc.Passage? = nil,
            members:[Unidoc.TopicMember])
        {
            self.context = context
            self.caption = caption
            self.members = members
        }
    }
}
extension Unidoc._LegacyTopic:Unidoc.CollapsibleContent
{
    var length:Int { self.members.count }
    var count:Int { self.members.count }
}
extension Unidoc._LegacyTopic:HTML.OutputStreamable
{
    static
    func += (section:inout HTML.ContentEncoder, self:Self)
    {
        section ?= self.caption.map
        {
            Unidoc.ProseSection.init(overview: $0, context: self.context)
        }

        section[.ul, { $0.class = "cards" }]
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

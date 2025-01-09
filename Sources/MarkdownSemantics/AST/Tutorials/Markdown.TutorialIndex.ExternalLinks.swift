import Sources

extension Markdown.TutorialIndex
{
    class ExternalLinks:Markdown.BlockContainer<Markdown.BlockElement>
    {
        var source:SourceReference<Markdown.Source>?

        var destination:String?
        var title:String?

        init()
        {
            self.source = nil

            self.destination = nil
            self.title = nil
            super.init([])
        }

        class
        var titleDefault:String? { nil }

        final override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            binary[.section]
            {
                let title:String? = self.title ?? Self.titleDefault

                if  let destination:String = self.destination
                {
                    $0[.h3] { $0[.a] { $0[.href] = destination } = title }
                }
                else
                {
                    $0[.h3] { $0[.id] = title } = title
                }

                super.emit(into: &$0)
            }
        }
    }
}
extension Markdown.TutorialIndex.ExternalLinks:Markdown.BlockDirectiveType
{
    enum Option:String, Markdown.BlockDirectiveOption
    {
        case destination
        case title, name
    }

    final
    func configure(option:Option, value:Markdown.SourceString) throws
    {
        switch option
        {
        case .destination:
            guard case nil = self.destination
            else
            {
                throw option.duplicate
            }

        case .title, .name:
            guard case nil = self.title
            else
            {
                throw option.duplicate
            }

            self.title = value.string
        }
    }
}

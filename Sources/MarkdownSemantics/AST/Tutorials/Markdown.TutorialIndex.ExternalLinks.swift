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
    final
    func configure(option:String, value:Markdown.SourceString) throws
    {
        switch option
        {
        case "destination":
            guard case nil = self.destination
            else
            {
                throw ArgumentError.duplicated(option)
            }

        case "title", "name":
            guard case nil = self.title
            else
            {
                throw ArgumentError.duplicated(option)
            }

            self.title = value.string

        case let option:
            throw ArgumentError.unexpected(option)
        }
    }
}

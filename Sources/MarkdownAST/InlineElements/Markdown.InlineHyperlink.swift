import MarkdownABI
import Sources

extension Markdown
{
    @frozen public
    struct InlineHyperlink
    {
        public
        var elements:[InlineSpan]
        public
        var target:Target?

        @inlinable internal
        init(target:Target?, elements:[InlineSpan])
        {
            self.elements = elements
            self.target = target
        }
    }
}
extension Markdown.InlineHyperlink
{
    public
    init(source:SourceReference<Markdown.Source>,
        target:String?,
        elements:[Markdown.InlineSpan])
    {
        if  let target:String,
                target.startIndex < target.endIndex
        {
            self.init(target: .init(source: source, target: target), elements: elements)
        }
        else
        {
            self.init(target: nil, elements: elements)
        }
    }
}
extension Markdown.InlineHyperlink
{
    /// Creates a link element using the given URL as both the link target and the
    /// link text.
    @inlinable public
    init(source:SourceReference<Markdown.Source>, url:String)
    {
        self.init(source: source, target: url, elements: [.text(url)])
    }
}
extension Markdown.InlineHyperlink:Markdown.TreeElement
{
    public
    func emit(into binary:inout Markdown.BinaryEncoder)
    {
        guard
        let target:Target = self.target
        else
        {
            for element:Markdown.InlineSpan in self.elements
            {
                element.emit(into: &binary)
            }
            return
        }

        binary[.a]
        {
            switch target
            {
            case .outlined(let reference):
                $0[.href] = reference

            case .urlFragment(let target):
                $0[.href] = "#\(target)"

            case .url(let url):
                guard
                let scheme:String = url.scheme
                else
                {
                    //  This will almost certainly be invalid, so there is no point encoding it.
                    break
                }

                if  scheme == "doc"
                {
                    //  This will never work, so there is no point encoding it.
                    break
                }

                $0[.external] = "\(url)"
            }
        }
            content:
        {
            for element:Markdown.InlineSpan in self.elements
            {
                element.emit(into: &$0)
            }
        }
    }
}
extension Markdown.InlineHyperlink:Markdown.TextElement
{
    @inlinable public static
    func += (text:inout String, self:Self)
    {
        for element:Markdown.InlineSpan in self.elements
        {
            text += element
        }
    }

    @inlinable public mutating
    func rewrite(by rewrite:(inout Markdown.InlineHyperlink.Target?) throws -> ()) rethrows
    {
        try rewrite(&self.target)
    }

    @inlinable public mutating
    func outline(by register:(Markdown.AnyReference) throws -> Int?) rethrows
    {
        let reference:Markdown.AnyReference
        switch self.target
        {
        case .none:             return
        case .outlined?:        return
        case .urlFragment?:     return
        case .url(let url)?:    reference = .link(url: url)
        }

        if  let reference:Int = try register(reference)
        {
            self.target = .outlined(reference)
        }
    }
}

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
    @inlinable public
    init(source:SourceReference<Markdown.Source>,
        target:String?,
        elements:[Markdown.InlineSpan])
    {
        guard
        let target:String,
            target.startIndex < target.endIndex
        else
        {
            self.init(target: nil, elements: elements)
            return
        }

        switch target[target.startIndex]
        {
        case "/":
            self.init(target: .absolute(.init(
                    source: source,
                    string: target)),
                elements: elements)

        case "#":
            let i:String.Index = target.index(after: target.startIndex)
            self.init(target: .fragment(.init(
                    source: source,
                    string: String.init(target[i...]))),
                elements: elements)

        case ".":
            let trimmed:Markdown.SourceString
            let i:String.Index = target.index(after: target.startIndex)
            if  i < target.endIndex, target[i] == "/"
            {
                let j:String.Index = target.index(after: i)
                if  j == target.endIndex
                {
                    self.init(target: nil, elements: elements)
                    return
                }

                trimmed = .init(source: source, string: String.init(target[j...]))
            }
            else
            {
                trimmed = .init(source: source, string: target)
            }

            self.init(target: .relative(trimmed), elements: elements)

        default:
            self.init(target: .external(.init(
                    source: source,
                    string: target)),
                elements: elements)
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
            //  These will almost certainly be invalid, so there is no point in encoding them.
            case .absolute:                 break
            case .relative:                 break
            case .external(let url):        $0[.external] = url.string
            case .fragment(let fragment):   $0[.href] = "#\(fragment.string)"
            case .outlined(let reference):  $0[.href] = reference
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
        switch self.target
        {
        case    nil, .outlined?, .fragment?:
            return

        case    .relative(let link)?,
                .absolute(let link)?,
                .external(let link)?:
            if  let reference:Int = try register(.link(link))
            {
                self.target = .outlined(reference)
            }
        }
    }
}

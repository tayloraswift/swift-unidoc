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
    init(source:SourceReference<MarkdownSource>,
        target:String?,
        elements:[Markdown.InlineSpan])
    {
        guard let target:String
        else
        {
            self.init(target: nil as Target?, elements: elements)
            return
        }

        if  let start:String.Index = target.index(target.startIndex,
                offsetBy: 2,
                limitedBy: target.endIndex),
            target[..<start] == "./"
        {
            self.init(target: .safe(String.init(target[start...]), source), elements: elements)
        }
        else
        {
            self.init(target: .unsafe(target), elements: elements)
        }
    }
}
extension Markdown.InlineHyperlink
{
    /// Creates a link element using the given URL as both the link target and the
    /// link text.
    @inlinable public
    init(source:SourceReference<MarkdownSource>, url:String)
    {
        self.init(source: source, target: url, elements: [.text(url)])
    }
}
extension Markdown.InlineHyperlink:Markdown.TreeElement
{
    @inlinable public mutating
    func outline(by register:(Markdown.InlineAutolink) throws -> Int?) rethrows
    {
        if  case .safe(let expression, let source)? = self.target,
            let reference:Int = try register(.init(source: source,
                text: expression,
                code: false))
        {
            self.target = .outlined(reference)
        }
    }

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
            case .outlined(let reference):  $0[.href] = reference
            case .safe(let url, _):         $0[.href] = url
            case .unsafe(let url):          $0[.external] = url
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
}

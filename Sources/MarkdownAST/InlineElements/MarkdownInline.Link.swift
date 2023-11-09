import MarkdownABI
import Sources

extension MarkdownInline
{
    @frozen public
    struct Link
    {
        public
        var elements:[MarkdownInline]
        public
        var target:Target?

        @inlinable internal
        init(target:Target?, elements:[MarkdownInline])
        {
            self.elements = elements
            self.target = target
        }
    }
}
extension MarkdownInline.Link
{
    @inlinable public
    init(target:String?, elements:[MarkdownInline], source:SourceReference<Int>?)
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
extension MarkdownInline.Link
{
    /// Creates a link element using the given URL as both the link target and the
    /// link text.
    @inlinable public
    init(url:String)
    {
        self.init(target: url, elements: [.text(url)], source: nil)
    }
}
extension MarkdownInline.Link:MarkdownElement
{
    @inlinable public mutating
    func outline(by register:(MarkdownInline.Autolink) throws -> Int?) rethrows
    {
        if  case .safe(let expression, let source)? = self.target,
            let reference:Int = try register(.init(expression, code: false, source: source))
        {
            self.target = .outlined(reference)
        }
    }

    public
    func emit(into binary:inout MarkdownBinaryEncoder)
    {
        binary[.a]
        {
            switch self.target
            {
            case .outlined(let reference)?: $0[.href] = reference
            case .safe(let url, _)?:        $0[.href] = url
            case .unsafe(let url)?:         $0[.external] = url
            case nil:                       return
            }
        }
            content:
        {
            for element:MarkdownInline in self.elements
            {
                element.emit(into: &$0)
            }
        }
    }
}
extension MarkdownInline.Link:MarkdownText
{
    @inlinable public
    var text:String
    {
        self.elements.lazy.map(\.text).joined()
    }
}

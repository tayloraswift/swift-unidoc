import MarkdownABI

extension Markdown
{
    /// Not to be confused with ``Markdown.BlockElement``.
    @frozen public
    enum InlineElement
    {
        case autolink(InlineAutolink)

        case container(InlineContainer<Self>)

        case code(InlineCode)
        case html(InlineHTML)
        case link(InlineHyperlink)
        case image(InlineImage)

        case reference(Int)

        case text(String)
    }
}
extension Markdown.InlineElement:Markdown.TreeElement
{
    @inlinable public
    func emit(into binary:inout Markdown.BinaryEncoder)
    {
        switch self
        {
        case .autolink(let autolink):
            autolink.element.emit(into: &binary)

        case .container(let container):
            container.emit(into: &binary)

        case .code(let code):
            code.emit(into: &binary)

        case .html(let html):
            html.emit(into: &binary)

        case .image(let image):
            image.emit(into: &binary)

        case .link(let link):
            link.emit(into: &binary)

        case .reference(let reference):
            binary &= reference

        case .text(let unescaped):
            binary += unescaped
        }
    }
}
extension Markdown.InlineElement:Markdown.TextElement
{
    @inlinable public static
    func += (text:inout String, self:Self)
    {
        switch self
        {
        case .autolink(let autolink):   text += autolink.text.string
        case .container(let container): text += container
        case .code(let code):           text += code
        case .html:                     return
        case .image(let image):         text += image
        case .link(let link):           text += link
        case .reference:                return
        case .text(let part):           text += part
        }
    }

    @inlinable public mutating
    func rewrite(by rewrite:(inout Markdown.InlineHyperlink.Target?) throws -> ()) rethrows
    {
        switch /* consume */ self
        {
        case .container(var container):
            defer { self = .container(container) }
            try container.rewrite(by: rewrite)

        case .link(var link):
            defer { self = .link(link) }
            try link.rewrite(by: rewrite)

        case let ignored:
            self = ignored
        }
    }

    @inlinable public mutating
    func outline(by register:(Markdown.AnyReference) throws -> Int?) rethrows
    {
        switch /* consume */ self
        {
        case .autolink(let autolink):
            guard
            let reference:Int = try register(.init(autolink))
            else
            {
                self = .autolink(autolink)
                return
            }

            self = .reference(reference)

        case .container(var container):
            defer { self = .container(container) }
            try container.outline(by: register)

        case .code(let code):
            self = .code(code)

        case .html(let html):
            self = .html(html)

        case .image(var image):
            defer { self = .image(image) }
            try image.outline(by: register)

        case .link(var link):
            defer { self = .link(link) }
            try link.outline(by: register)

        case .reference(let reference):
            self = .reference(reference)

        case .text(let text):
            self = .text(text)
        }
    }
}
extension Markdown.InlineElement
{
    /// Returns true if this element can appear as link text.
    @inlinable internal
    var anchorable:Bool
    {
        switch self
        {
        case .autolink:                 false
        case .container(let container): container.anchorable
        case .code:                     true
        case .html:                     false
        case .image:                    false
        case .link:                     false
        case .reference:                false
        case .text:                     true
        }
    }
}

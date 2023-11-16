import MarkdownABI

extension MarkdownInline
{
    @frozen public
    enum Block
    {
        case autolink(Autolink)

        case container(Container<Self>)

        case code(Code)
        case html(HTML)
        case link(Link)
        case image(Image)

        case reference(Int)

        case text(String)
    }
}
extension MarkdownInline.Block:MarkdownElement
{
    @inlinable public mutating
    func outline(by register:(MarkdownInline.Autolink) throws -> Int?) rethrows
    {
        switch self
        {
        case .autolink(let autolink):
            if  let reference:Int = try register(autolink)
            {
                self = .reference(reference)
            }

        case .container(var container):
            self = .text("")
            defer { self = .container(container) }
            try container.outline(by: register)

        case .link(var link):
            self = .text("")
            defer { self = .link(link) }
            try link.outline(by: register)

        case .code, .html, .image, .reference, .text:
            return
        }
    }

    @inlinable public
    func emit(into binary:inout MarkdownBinaryEncoder)
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
extension MarkdownInline.Block:MarkdownText
{
    @inlinable public static
    func += (text:inout String, self:Self)
    {
        switch self
        {
        case .autolink(let autolink):   text += autolink.text
        case .container(let container): text += container
        case .code(let code):           text += code
        case .html:                     return
        case .image(let image):         text += image
        case .link(let link):           text += link
        case .reference:                return
        case .text(let part):           text += part
        }
    }
}
extension MarkdownInline.Block
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

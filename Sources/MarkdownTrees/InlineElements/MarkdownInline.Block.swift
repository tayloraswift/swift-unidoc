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
    @inlinable public
    var text:String
    {
        switch self
        {
        case .autolink(let autolink):
            return autolink.text

        case .container(let container):
            return container.text

        case .code(let code):
            return code.text

        case .html, .reference:
            return ""

        case .image(let image):
            return image.text

        case .link(let link):
            return link.text

        case .text(let text):
            return text
        }
    }
}

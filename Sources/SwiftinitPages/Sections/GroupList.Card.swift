import HTML
import UnidocRecords

extension GroupList
{
    struct Card
    {
        let overview:ProseSection?

        let vertex:Unidoc.AnyVertex
        let target:String?

        init(overview:ProseSection?, vertex:Unidoc.AnyVertex, target:String?)
        {
            self.overview = overview
            self.vertex = vertex
            self.target = target
        }
    }
}
extension GroupList.Card:HTML.OutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        switch self.vertex
        {
        case .product(let vertex):
            html[.li, { $0.class = "product" }]
            {
                $0[.span]
                {
                    $0[link: self.target] = vertex.symbol

                    let tag:String
                    switch vertex.type
                    {
                    case .executable:   tag = "executable"
                    case .library:      tag = "library"
                    case .macro:        tag = "macro"
                    case .plugin:       tag = "plugin"
                    case .snippet:      tag = "snippet"
                    case .test:         tag = "test"
                    }

                    $0[.span] { $0.class = "parenthetical" } = tag
                }

                //  Should always be nil right now, but eventually we want to support this.
                $0 ?= self.overview
            }

        case .culture(let vertex):
            html[.li, { $0.class = "module" }]
            {
                $0[.span]
                {
                    $0[link: self.target] = vertex.module.name

                    let tag:String
                    switch vertex.module.type
                    {
                    case .binary:       return
                    case .executable:   tag = "executable"
                    case .regular:      return
                    case .macro:        tag = "macro"
                    case .plugin:       tag = "plugin"
                    case .snippet:      tag = "snippet"
                    case .system:       tag = "system"
                    case .test:         tag = "test"
                    }

                    $0[.span] { $0.class = "parenthetical" } = tag
                }

                $0 ?= self.overview
            }

        case .article(let vertex):
            html[.li, { $0.class = "article" }]
            {
                $0[link: self.target] { $0[.h3] = vertex.headline.safe }
                $0 ?= self.overview
                $0[link: self.target] { $0.class = "read-more" } = "Read More"
            }

        case .decl(let vertex):
            html[.li, { $0.class = "decl" ; $0.id = "\(vertex.symbol)" }]
            {
                $0[.a] { $0.href = "#\(vertex.symbol)" }

                //  There is no better way to compute the monospace width of markdown than
                //  rendering it to plain text and performing grapheme breaking.
                let width:Int = "\(vertex.signature.abridged.bytecode.safe)".count

                //  The em width of a single glyph of the IBM Plex Mono font is 600 / 1000,
                //  or 0.6. We consider a signature to be “long” if it occupies more than
                //  48 em units. Therefore the threshold is 48 / 0.6 = 80 characters.
                $0[.code, { $0.class = width > 80 ? "multiline" : nil }]
                {
                    $0[link: self.target]
                    {
                        $0.class = vertex.signature.availability.isGenerallyRecommended ?
                            nil : "discouraged"
                    } = vertex.signature.abridged
                }

                $0 ?= self.overview
            }

        case .file, .foreign, .global:
            //  unimplemented
            break
        }
    }
}

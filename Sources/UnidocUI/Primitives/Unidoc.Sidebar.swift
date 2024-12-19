import HTML
import Symbols
import UnidocQueries
import UnidocRecords
import URI

extension Unidoc
{
    struct Sidebar<Root> where Root:Unidoc.VertexLayer
    {
        private
        let volume:Unidoc.VolumeMetadata
        private
        let origin:Symbol.Module?
        private
        let nouns:[Unidoc.Noun]

        private
        init(volume:Unidoc.VolumeMetadata, origin:Symbol.Module?, nouns:[Unidoc.Noun])
        {
            self.volume = volume
            self.origin = origin
            self.nouns = nouns
        }
    }
}
extension Unidoc.Sidebar
{
    static
    func package(volume:Unidoc.VolumeMetadata) -> Self
    {
        .init(volume: volume, origin: nil, nouns: volume.cultures)
    }

    static
    func product(volume:Unidoc.VolumeMetadata) -> Self
    {
        .init(volume: volume, origin: nil, nouns: volume.products)
    }

    static
    func module(volume:Unidoc.VolumeMetadata,
        origin:Symbol.Module?,
        tree:Unidoc.TypeTree?) -> Self
    {
        .init(volume: volume, origin: origin, nouns: tree?.rows ?? [])
    }
}
extension Unidoc.Sidebar:HTML.OutputStreamable
{
    static func += (html:inout HTML.ContentEncoder, self:Self)
    {
        //  Unfortunately, this cannot be a proper `ul`, because `ul` cannot contain another
        //  `ul` as a direct child.
        html[.div, { $0.class = "nountree" }]
        {
            var previous:Unidoc.Stem = ""
            var depth:Int = 1

            for noun:Unidoc.Noun in self.nouns
            {
                let (name, indents):(Substring, Int) = noun.shoot.stem.relative(to: previous)

                if  indents < depth
                {
                    for _:Int in indents ..< depth
                    {
                        $0.close(.div)
                    }
                }
                else
                {
                    for _:Int in depth ..< indents
                    {
                        $0.open(.div) { $0.class = "indent" }
                    }
                }

                previous = noun.shoot.stem
                depth = indents

                var uri:URI { Root[self.volume, noun.route] }

                switch noun.type
                {
                case .text(let text):
                    $0[.a] { $0.href = "\(uri)" ; $0.class = "text" } = text

                case .stem(let citizenship, _):
                    $0[.a]
                    {
                        if  let origin:Symbol.Module = self.origin, citizenship != .culture
                        {
                            $0.href = "\(uri)#sm:\(origin)"
                        }
                        else
                        {
                            $0.href = "\(uri)"
                        }

                        switch citizenship
                        {
                        case .culture:  break
                        case .package:  $0.class = "extension local"
                        case .foreign:  $0.class = "extension foreign"
                        }

                    } = name
                }
            }
            for _:Int in 1 ..< depth
            {
                $0.close(.div)
            }
        }
    }
}

import HTML
import UnidocQueries
import UnidocRecords
import URI

extension Swiftinit
{
    @frozen public
    struct Sidebar<Root> where Root:Unidoc.VertexLayer
    {
        private
        let volume:Unidoc.VolumeMetadata
        private
        let nouns:[Unidoc.Noun]

        private
        init(volume:Unidoc.VolumeMetadata, nouns:[Unidoc.Noun])
        {
            self.volume = volume
            self.nouns = nouns
        }
    }
}
extension Swiftinit.Sidebar
{
    static
    func package(volume:Unidoc.VolumeMetadata) -> Self
    {
        .init(volume: volume, nouns: volume.cultures)
    }

    static
    func product(volume:Unidoc.VolumeMetadata) -> Self
    {
        .init(volume: volume, nouns: volume.products)
    }

    static
    func module(volume:Unidoc.VolumeMetadata, tree:Unidoc.TypeTree?) -> Self?
    {
        guard
        let nouns:[Unidoc.Noun] = tree?.rows
        else
        {
            return nil
        }

        return .init(volume: volume, nouns: nouns)
    }
}
extension Swiftinit.Sidebar:HTML.OutputStreamable
{
    public static
    func += (html:inout HTML.ContentEncoder, self:Self)
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
                        $0.href = "\(uri)"

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

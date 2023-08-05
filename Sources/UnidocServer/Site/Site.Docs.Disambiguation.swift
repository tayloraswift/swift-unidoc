import HTML
import Unidoc
import UnidocQueries
import UnidocRecords
import URI

extension Site.Docs
{
    struct Disambiguation
    {
        private
        let inliner:Inliner

        let identity:URI.Path
        let location:URI
        let matches:[Unidoc.Scalar]

        private
        init(_ inliner:Inliner, identity:URI.Path, location:URI, matches:[Unidoc.Scalar])
        {
            self.inliner = inliner

            self.identity = identity
            self.location = location
            self.matches = matches
        }
    }
}
extension Site.Docs.Disambiguation
{
    init?(matches:[Record.Master], in trunk:Record.Trunk)
    {
        guard let first:Record.Master = matches.first
        else
        {
            return nil
        }

        var identity:URI.Path = []

        if  let stem:Record.Stem = first.stem
        {
            identity += stem
        }

        let location:URI

        switch first
        {
        case .article(let first):   location = .init(article: first, in: trunk)
        case .culture(let first):   location = .init(culture: first, in: trunk)
        case .decl(let first):      location = .init(decl: first, in: trunk,
            disambiguate: false)
        //  We should never get this as principal output!
        case .file:                 return nil
        }

        let inliner:Inliner = .init(principal: first.id.zone, zone: trunk)
            inliner.masters.add(matches)

        self.init(inliner, identity: identity, location: location, matches: matches.map(\.id))
    }
}
extension Site.Docs.Disambiguation:FixedPage
{
    var title:String { "Disambiguation Page" }

    func emit(main:inout HTML.ContentEncoder)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span, { $0.class = "phylum" }] = "Disambiguation Page"
            }

            $0[.h1] = "\(self.identity)"

            $0[.p] = "This path could refer to multiple entities."
        }
        main[.section, { $0.class = "group choices" }]
        {
            $0[.ul]
            {
                for match:Unidoc.Scalar in self.matches
                {
                    $0 ?= self.inliner.card(match)
                }
            }
        }
    }
}

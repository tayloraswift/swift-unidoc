import HTML
import SwiftinitRender
import UnidocDB
import UnixTime
import URI

extension Swiftinit.PackagesCreatedPage
{
    enum Heading
    {
        case free
        case unfree
        case inactive
    }
}
extension Swiftinit.PackagesCreatedPage.Heading:Identifiable
{
    var id:String
    {
        switch self
        {
        case .free:     "ss:free"
        case .unfree:   "ss:unfree"
        case .inactive: "ss:inactive"
        }
    }
}
extension Swiftinit.PackagesCreatedPage.Heading:HTML.OutputStreamableHeading
{
    var display:String
    {
        switch self
        {
        case .free:     "Free packages"
        case .unfree:   "Unfree packages"
        case .inactive: "Inactive packages"
        }
    }
}
extension Swiftinit
{
    struct PackagesCreatedPage
    {
        private
        let date:Timestamp.Date
        private
        let inactive:[Unidoc.PackageOutput]
        private
        let unfree:[Unidoc.PackageOutput]
        private
        let free:[Unidoc.PackageOutput]

        private
        init(date:Timestamp.Date,
            inactive:[Unidoc.PackageOutput],
            unfree:[Unidoc.PackageOutput],
            free:[Unidoc.PackageOutput])
        {
            self.date = date
            self.inactive = inactive
            self.unfree = unfree
            self.free = free
        }
    }
}
extension Swiftinit.PackagesCreatedPage
{
    init(_ packages:consuming [Unidoc.PackageOutput], on date:Timestamp.Date)
    {
        var packages:
        (
            inactive:[Unidoc.PackageOutput],
            unfree:[Unidoc.PackageOutput],
            free:[Unidoc.PackageOutput]
        ) = packages.reduce(into: ([], [], []))
        {
            if  case false = $1.metadata.repo?.origin.alive
            {
                $0.inactive.append($1)
                return
            }
            guard
            let license:Unidoc.PackageLicense = $1.metadata.repo?.license
            else
            {
                $0.unfree.append($1)
                return
            }
            switch license.spdx
            {
            case    "NOASSERTION",
                    "NONE":
                $0.unfree.append($1)

            //  We don’t know enough about licenses to know if they are free or not, and
            //  Swiftinit does not provide legal advice.
            default:
                $0.free.append($1)
            }
        }

        packages.inactive.sort { $0.metadata.symbol < $1.metadata.symbol }
        packages.unfree.sort { $0.metadata.symbol < $1.metadata.symbol }
        packages.free.sort { $0.metadata.symbol < $1.metadata.symbol }

        self.init(date: date,
            inactive: packages.inactive,
            unfree: packages.unfree,
            free: packages.free)
    }
}
extension Swiftinit.PackagesCreatedPage:Swiftinit.RenderablePage
{
    var title:String { "Packages · \(self.date)" }
}
extension Swiftinit.PackagesCreatedPage:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.Telescope[self.date] }
}
extension Swiftinit.PackagesCreatedPage:Swiftinit.ApplicationPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.h1] = self.date.short(.en)
        }

        main[.section, { $0.class = "details" }]
        {
            if  self.inactive.isEmpty,
                self.unfree.isEmpty,
                self.free.isEmpty
            {
                $0[.p] = "No Swift repositories were created on \(self.date.long(.en))."
                return
            }

            for (heading, group):(Heading?, [Unidoc.PackageOutput]) in
            [
                (nil, self.free),
                (.unfree, self.unfree),
                (.inactive, self.inactive),
            ]
            {
                if  group.isEmpty
                {
                    continue
                }

                $0[.h2] = heading
                $0[.ol, { $0.class = "packages" }]
                {
                    for package:Unidoc.PackageOutput in group
                    {
                        $0[.li] = Swiftinit.PackageCard.init(package)
                    }
                }
            }
        }
    }
}

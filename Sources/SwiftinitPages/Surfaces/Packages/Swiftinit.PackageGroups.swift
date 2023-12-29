import HTML

extension Swiftinit
{
    struct PackageGroups
    {
        private
        let heading:Heading?

        private
        let free:[PackageCard]
        private
        let unfree:[PackageCard]
        private
        let inactive:[PackageCard]

        private
        init(heading:Heading?,
            free:[PackageCard],
            unfree:[PackageCard],
            inactive:[PackageCard])
        {
            self.heading = heading
            self.free = free
            self.unfree = unfree
            self.inactive = inactive
        }
    }
}
extension Swiftinit.PackageGroups
{
    init(organizing packages:consuming [Unidoc.PackageOutput], heading:Heading? = nil)
    {
        var packages:
        (
            inactive:[Swiftinit.PackageCard],
            unfree:[Swiftinit.PackageCard],
            free:[Swiftinit.PackageCard]
        ) = packages.reduce(into: ([], [], []))
        {
            if  case false = $1.metadata.repo?.origin.alive
            {
                $0.inactive.append(.init($1))
                return
            }
            guard
            let license:Unidoc.PackageLicense = $1.metadata.repo?.license
            else
            {
                $0.unfree.append(.init($1))
                return
            }
            switch license.spdx
            {
            case    "NOASSERTION",
                    "NONE":
                $0.unfree.append(.init($1))

            //  We don’t know enough about licenses to know if they are free or not, and
            //  Swiftinit does not provide legal advice.
            default:
                $0.free.append(.init($1))
            }
        }

        //  Pre-sort the packages to prevent content flashing.
        packages.inactive.sort { $0.order < $1.order }
        packages.unfree.sort { $0.order < $1.order }
        packages.free.sort { $0.order < $1.order }

        self.init(heading: heading,
            free: packages.free,
            unfree: packages.unfree,
            inactive: packages.inactive)
    }
}
extension Swiftinit.PackageGroups
{
    var isEmpty:Bool
    {
        self.free.isEmpty && self.unfree.isEmpty && self.inactive.isEmpty
    }
}
extension Swiftinit.PackageGroups
{
    enum SortOption
    {
        case name
        case owner
        case stars
    }
}
extension Swiftinit.PackageGroups.SortOption:Identifiable
{
    var id:String
    {
        switch self
        {
        case .name:     "name"
        case .owner:    "owner"
        case .stars:    "stars"
        }
    }
}
extension Swiftinit.PackageGroups.SortOption
{
    var label:String
    {
        switch self
        {
        case .name:     "name"
        case .owner:    "owner"
        case .stars:    "stars"
        }
    }
    var predicate:String?
    {
        switch self
        {
        case .name:     nil
        case .owner:    nil
        case .stars:    "number-desc"
        }
    }
}
extension Swiftinit.PackageGroups:HTML.OutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        var heading:Heading? = self.heading

        for (type, group):(Heading?, [Swiftinit.PackageCard]) in
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

            defer
            {
                heading = nil
            }

            html[.h2] = heading ?? type
            html[.form, { $0.class = "packages sort-controls" }]
            {
                $0[.fieldset]
                {
                    $0[.legend] = "Sort by"

                    for option:SortOption in [.name, .owner, .stars]
                    {
                        $0[.label]
                        {
                            $0[.input]
                            {
                                $0.type = "radio"
                                $0.name = "sort"
                                $0.value = option.id
                                $0.checked = option == .name

                                $0[data: "predicate"] = option.predicate
                            }
                            $0 += option.label
                        }
                    }
                }
            }
            html[.ol, { $0.class = "packages" }]
            {
                for package:Swiftinit.PackageCard in group
                {
                    $0[.li]
                    {
                        $0[data: SortOption.stars.id] = "\(package.stars ?? 0)"
                        $0[data: SortOption.owner.id] = package.owner ?? ""
                        $0[data: SortOption.name.id] = package.name

                    } = package
                }
            }
        }
    }
}

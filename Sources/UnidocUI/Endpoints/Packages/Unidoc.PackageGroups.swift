import HTML
import UnixTime

extension Unidoc
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
extension Unidoc.PackageGroups
{
    init(organizing packages:consuming [Unidoc.EditionOutput],
        heading:Heading? = nil,
        now:UnixAttosecond)
    {
        var packages:
        (
            inactive:[Unidoc.PackageCard],
            unfree:[Unidoc.PackageCard],
            free:[Unidoc.PackageCard]
        ) = packages.reduce(into: ([], [], []))
        {
            if  case false? = $1.package.repo?.origin.alive
            {
                $0.inactive.append(.init($1, now: now))
            }
            else if
                case true? = $1.package.repo?.license?.free
            {
                $0.free.append(.init($1, now: now))
            }
            else
            {
                $0.unfree.append(.init($1, now: now))
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
extension Unidoc.PackageGroups
{
    var isEmpty:Bool
    {
        self.free.isEmpty && self.unfree.isEmpty && self.inactive.isEmpty
    }

    var count:Int
    {
        self.free.count + self.unfree.count + self.inactive.count
    }
}
extension Unidoc.PackageGroups
{
    enum SortOption
    {
        case name
        case owner
        case stars
    }
}
extension Unidoc.PackageGroups.SortOption:Identifiable
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
extension Unidoc.PackageGroups.SortOption
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
extension Unidoc.PackageGroups:HTML.OutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        var heading:Heading? = self.heading

        for (type, group):(Heading?, [Unidoc.PackageCard]) in
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
                for package:Unidoc.PackageCard in group
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

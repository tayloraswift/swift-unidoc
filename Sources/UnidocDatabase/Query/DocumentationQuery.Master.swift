import FNV1
import ModuleGraphs
import MongoDB

extension DocumentationQuery
{
    struct Master
    {
        let package:PackageIdentifier
        let version:Substring?
        let stem:Substring
        let hash:FNV24?

        init(package:PackageIdentifier,
            version:Substring?,
            stem:Substring,
            hash:FNV24?)
        {
            self.package = package
            self.version = version
            self.stem = stem
            self.hash = hash
        }
    }
}
extension DocumentationQuery.Master
{
    static
    var collation:Mongo.Collation
    {
        .init(locale: "en", // casing is a property of english, not unicode
            caseLevel: false, // url paths are case-insensitive
            normalization: true, // normalize unicode on insert
            strength: .secondary) // diacritics are significant
    }

    var command:Mongo.Aggregate<Mongo.Cursor<DocumentationPage>>
    {
        .init(DocumentationDatabase.Zones.name,
            pipeline: .init
            {
                //  Phase I: Look up the zone to search in. If a version string
                //  was provided, use that to filter between multiple versions
                //  of the same package. If any snapshots with semantic versions
                //  match, pick the one with the highest semantic version.
                $0.stage
                {
                    $0[.match] = .init
                    {
                        $0[Record.Zone[.package]] = package
                        $0[Record.Zone[.version]] = version
                    }
                }
                $0.stage
                {
                    $0[.sort] = .init
                    {
                        $0[Record.Zone[.recency]] = (-)
                    }
                }
                $0.stage
                {
                    $0[.limit] = 1
                }

                $0.stage
                {
                    $0[.lookup] = .init
                    {
                        $0[.from] = DocumentationDatabase.Masters.name
                        $0[.let] = .init
                        {
                            $0["min"] = "$\(Record.Zone[.min])"
                            $0["max"] = "$\(Record.Zone[.max])"
                        }
                        $0[.pipeline] = .init
                        {
                            $0.stage
                            {
                                $0[.match] = .init
                                {
                                    $0[Record.Master[.stem]] = stem
                                    $0[.expr] = .init
                                    {
                                        $0[.and] =
                                        (
                                            .init
                                            {
                                                $0[.gte] =
                                                (
                                                    "$\(Record.Master[.id])",
                                                    "$$min"
                                                )
                                            },
                                            .init
                                            {
                                                $0[.lte] =
                                                (
                                                    "$\(Record.Master[.id])",
                                                    "$$max"
                                                )
                                            }
                                        )
                                    }
                                }
                            }
                            $0.stage
                            {
                                $0[.limit] = 50
                            }
                        }
                        $0[.as] = DocumentationPage[.matches]
                    }
                }
                $0.stage
                {
                    $0[.set] = .init
                    {
                        $0[DocumentationPage[.master]] = .init
                        {
                            $0[.first] = "$\(DocumentationPage[.matches])"
                        }
                    }
                }
            },
            stride: 50)
        {
            $0[.collation] = Self.collation
            $0[.hint] = .init
            {
                $0[Record.Zone[.package]] = (+)
                $0[Record.Zone[.version]] = (+)
                $0[Record.Zone[.recency]] = (-)
            }
        }
    }
}

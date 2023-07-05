import BSONEncoding
import FNV1
import ModuleGraphs
import MongoDB

public
struct DocpageQuery
{
    let package:PackageIdentifier
    let version:Substring?
    let stem:Substring
    let hash:FNV24?

    public
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
extension DocpageQuery
{
    static
    var collation:Mongo.Collation
    {
        .init(locale: "en", // casing is a property of english, not unicode
            caseLevel: false, // url paths are case-insensitive
            normalization: true, // normalize unicode on insert
            strength: .secondary) // diacritics are significant
    }

    public
    var command:Mongo.Aggregate<Mongo.Cursor<Docpage>>
    {
        //  The `$facet` stage in ``pipeline`` should collect all records into a
        //  single document, so this pipeline should return at most 1 element.
        .init(DocumentationDatabase.Zones.name, pipeline: self.pipeline, stride: 1)
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
extension DocpageQuery
{
    private
    var pipeline:Mongo.Pipeline
    {
        .init
        {
            //  Look up the zone to search in. If a version string was provided,
            //  use that to filter between multiple versions of the same package.
            //  If any snapshots with semantic versions match, pick the one with
            //  the highest semantic version.
            $0.stage
            {
                $0[.match] = .init
                {
                    $0[Record.Zone[.package]] = self.package
                    $0[Record.Zone[.version]] = self.version
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

            //  Find at least one master record that has a matching url stem,
            //  within the zone of scalars we obtained from the previous stage.
            //  (The stems do not encode snapshot information.)
            $0.stage
            {
                $0[.lookup] = .init
                {
                    let min:Mongo.UntypedVariable = "min"
                    let max:Mongo.UntypedVariable = "max"

                    $0[.from] = DocumentationDatabase.Masters.name
                    $0[.let] = .init
                    {
                        $0[let: min] = "$\(Record.Zone[.min])"
                        $0[let: max] = "$\(Record.Zone[.max])"
                    }
                    $0[.pipeline] = .init
                    {
                        $0.stage
                        {
                            $0[.match] = .init
                            {
                                $0[Record.Master[.stem]] = self.stem
                                $0[.expr] = .expr
                                {
                                    $0[.and] =
                                    (
                                        .expr
                                        {
                                            $0[.gte] = ("$\(Record.Master[.id])", min)
                                        },
                                        .expr
                                        {
                                            $0[.lte] = ("$\(Record.Master[.id])", max)
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
                    $0[.as] = Docpage.Principal[.matches]
                }
            }
            $0.stage
            {
                $0[.set] = .init
                {
                    $0[Docpage.Principal[.master]] = .expr
                    {
                        $0[.first] = "$\(Docpage.Principal[.matches])"
                    }
                }
            }

            //  Gather all the extensions to the principal master record.
            $0.stage
            {
                $0[.lookup] = .init
                {
                    $0[.from] = DocumentationDatabase.Extensions.name
                    $0[.localField] = Docpage.Principal[.master] / Record.Master[.id]
                    $0[.foreignField] = Record.Extension[.scope]
                    $0[.as] = Docpage.Principal[.extensions]
                }
            }

            //  Extract (and de-duplicate) the scalars mentioned by the extensions.
            //  Store them in this temporary field:
            let scalars:BSON.Key = "scalars"

            $0.stage
            {
                $0[.set] = Mongo.SetDocument.init // helps typechecking massively
                {
                    $0[scalars] = .expr
                    {
                        $0[.setUnion] = .init
                        {
                            $0.expr
                            {
                                $0[.reduce] = .init
                                {
                                    $0[.input] = .expr
                                    {
                                        let variable:ExtensionVariable = "self"

                                        $0[.map] = .let(variable)
                                        {
                                            $0[.input] = "$\(Docpage.Principal[.extensions])"
                                            $0[.in] = variable.scalars
                                        }
                                    }
                                    $0[.initialValue] = [] as [Never]
                                    $0[.in] = .expr
                                    {
                                        $0[.concatArrays] = ("$$value", "$$this")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            $0.stage
            {
                $0[.facet] = .init
                {
                    $0[Docpage[.principal]] = .init
                    {
                        $0.stage
                        {
                            $0[.unset] = scalars
                        }
                    }
                    $0[Docpage[.entourage]] = .init
                    {
                        $0.stage
                        {
                            $0[.unwind] = "$\(scalars)"
                        }
                        $0.stage
                        {
                            $0[.lookup] = .init
                            {
                                $0[.from] = DocumentationDatabase.Masters.name
                                $0[.localField] = scalars
                                $0[.foreignField] = Record.Master[.id]
                                $0[.as] = "masters"
                            }
                        }
                        $0.stage
                        {
                            $0[.unwind] = "$masters"
                        }
                        $0.stage
                        {
                            $0[.replaceWith] = "$masters"
                        }
                        $0.stage
                        {
                            //  We do not need to load all the markdown for master
                            //  records in the entourage.
                            $0[.unset] = Record.Master[.details]
                        }
                    }
                }
            }
        }
    }
}

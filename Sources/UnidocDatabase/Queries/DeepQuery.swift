import BSONEncoding
import FNV1
import ModuleGraphs
import MongoDB
import UnidocRecords

/// A deep query is a query for a single code-level entity,
/// such as a declaration or a module.
@frozen public
struct DeepQuery
{
    let package:PackageIdentifier
    let version:Substring?
    private(set)
    var stem:String
    private(set)
    var hash:FNV24?

    private
    init(package:PackageIdentifier,
        version:Substring?,
        stem:String = "",
        hash:FNV24? = nil)
    {
        self.package = package
        self.version = version
        self.stem = stem
        self.hash = hash
    }
}
extension DeepQuery
{
    public
    init?(_ trunk:String, _ tail:ArraySlice<String>)
    {
        if  let colon:String.Index = trunk.firstIndex(of: ":")
        {
            self.init(package: .init(trunk[..<colon]), version: nil)
            self.append(component: trunk[trunk.index(after: colon)...])
            self.append(components: tail)
        }
        else if
            let next:String = tail.first,
            let colon:String.Index = next.firstIndex(of: ":")
        {
            self.init(package: .init(trunk), version: next[..<colon])
            self.append(component: next[next.index(after: colon)...])
            self.append(components: tail.dropFirst())
        }
        else
        {
            return nil
        }
    }

    private mutating
    func append(components:ArraySlice<String>)
    {
        for component:String in components
        {
            self.append(component: component)
        }
    }
    private mutating
    func append(component:some StringProtocol)
    {
        if !self.stem.isEmpty
        {
            self.stem.append(" ")
        }
        if  let dot:String.Index = component.firstIndex(of: ".")
        {
            self.stem += "\(component[..<dot])\t\(component[component.index(after: dot)...])"
        }
        else
        {
            self.stem += component
        }
    }
}

extension DeepQuery
{
    static
    var collation:Mongo.Collation
    {
        .init(locale: "en", // casing is a property of english, not unicode
            caseLevel: false, // url paths are case-insensitive
            normalization: true, // normalize unicode on insert
            strength: .secondary) // diacritics are significant
    }

    var command:Mongo.Aggregate<Mongo.Cursor<Output>>
    {
        //  The `$facet` stage in ``pipeline`` should collect all records into a
        //  single document, so this pipeline should return at most 1 element.
        .init(Database.Zones.name, pipeline: self.pipeline, stride: 1)
        {
            $0[.collation] = Self.collation
            $0[.hint] = .init
            {
                $0[Record.Zone[.package]] = (+)
                $0[Record.Zone[.version]] = (+)
                $0[Record.Zone[.patch]] = (-)
            }
        }
    }
}
extension DeepQuery
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
                    $0[Record.Zone[.patch]] = (-)
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

                    $0[.from] = Database.Masters.name
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
                    $0[.as] = Output.Principal[.matches]
                }
            }
            $0.stage
            {
                $0[.set] = .init
                {
                    //  Populate this field only if exactly one master record matched.
                    //  This allows us to skip looking up entourage records if we are
                    //  only going to generate a disambiguation page.
                    $0[Output.Principal[.master]] = .expr
                    {
                        $0[.cond] =
                        (
                            if: .expr
                            {
                                $0[.eq] =
                                (
                                    1, .expr { $0[.size] = "$\(Output.Principal[.matches])" }
                                )
                            },
                            then: .expr { $0[.first] = "$\(Output.Principal[.matches])" },
                            else: (nil as Never?) as Never??
                        )
                    }
                }
            }

            //  Gather all the extensions to the principal master record.
            $0.stage
            {
                $0[.lookup] = .init
                {
                    $0[.from] = Database.Extensions.name
                    $0[.localField] = Output.Principal[.master] / Record.Master[.id]
                    $0[.foreignField] = Record.Extension[.scope]
                    $0[.as] = Output.Principal[.extensions]
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
                                            $0[.input] = "$\(Output.Principal[.extensions])"
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
                    $0[Output[.principal]] = .init
                    {
                        $0.stage
                        {
                            $0[.project] = .init
                            {
                                for key:Output.Principal.CodingKeys in
                                        Output.Principal.CodingKeys.allCases
                                {
                                    $0[Output.Principal[key]] = true
                                }
                            }
                        }
                    }
                    $0[Output[.entourage]] = .init
                    {
                        $0.stage
                        {
                            $0[.unwind] = "$\(scalars)"
                        }
                        $0.stage
                        {
                            $0[.lookup] = .init
                            {
                                $0[.from] = Database.Masters.name
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

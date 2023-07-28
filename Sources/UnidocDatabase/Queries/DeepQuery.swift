import BSONEncoding
import FNV1
import ModuleGraphs
import MongoDB
import Signatures
import SymbolGraphs
import Unidoc
import UnidocRecords

/// A deep query is a query for a single code-level entity,
/// such as a declaration or a module.
@frozen public
struct DeepQuery
{
    let planes:Planes
    let package:PackageIdentifier
    let version:Substring?
    let stem:Record.Stem
    private(set)
    var hash:FNV24?

    private
    init(_ planes:Planes,
        package:PackageIdentifier,
        version:Substring?,
        stem:Record.Stem,
        hash:FNV24? = nil)
    {
        self.planes = planes

        self.package = package
        self.version = version
        self.stem = stem
        self.hash = hash
    }
}
extension DeepQuery
{
    public
    init?(_ planes:Planes, _ trunk:String, _ tail:ArraySlice<String>, hash:FNV24? = nil)
    {
        if  let colon:String.Index = trunk.firstIndex(of: ":")
        {
            self.init(planes,
                package: .init(trunk[..<colon]),
                version: nil,
                stem: .init(uri: (trunk[trunk.index(after: colon)...], tail)),
                hash: hash)
        }
        else if
            let next:String = tail.first,
            let colon:String.Index = next.firstIndex(of: ":")
        {
            self.init(planes,
                package: .init(trunk),
                version: next[..<colon],
                stem: .init(uri: (next[next.index(after: colon)...], tail.dropFirst())),
                hash: hash)
        }
        else
        {
            return nil
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
        return .init(Database.Zones.name, pipeline: self.pipeline, stride: 1)
        {
            $0[.collation] = Self.collation
            $0[.hint] = .init
            {
                $0[Record.Zone[.package]] = (+)

                if  case _? = self.version
                {
                    $0[Record.Zone[.version]] = (+)
                }
                else
                {
                    $0[Record.Zone[.patch]] = (-)
                }
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
            //  Look up the zone to search in.
            if  let version:Substring = self.version
            {
                //  If a version string was provided, use that to filter between
                //  multiple versions of the same package.
                //  This index is unique, so we don’t need a sort or a limit.
                $0.stage
                {
                    $0[.match] = .init
                    {
                        $0[Record.Zone[.package]] = self.package
                        $0[Record.Zone[.version]] = version
                    }
                }
            }
            else
            {
                //  If no version string was provided, pick the one with
                //  the highest semantic version. Unstable and prerelease
                //  versions are not eligible.
                //  This works a lot like ``Database.Zones.latest(of:with:)``,
                //  except it queries the package by name instead of id.
                $0.stage
                {
                    $0[.match] = .init
                    {
                        $0[Record.Zone[.package]] = self.package
                        $0[Record.Zone[.patch]] = .init
                        {
                            $0[.ne] = Never??.some(nil)
                        }
                    }
                }
                //  We use the patch number instead of the latest-flag because
                //  it is closer to the ground-truth, and the latest-flag doesn’t
                //  have a unique (compound) index with the package name, since
                //  it experiences rolling alignments.
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
            }

            //  Find at least one master record that has a matching url stem,
            //  within the zone of scalars we obtained from the previous stage.
            //  (The stems do not encode snapshot information.)
            $0.stage
            {
                $0[.lookup] = .init
                {
                    let min:Mongo.Variable<Unidoc.Scalar> = "min"
                    let max:Mongo.Variable<Unidoc.Scalar> = "max"

                    $0[.from] = Database.Masters.name
                    $0[.let] = .init
                    {
                        $0[let: min] = Record.Zone[self.planes.range.min]
                        $0[let: max] = Record.Zone[self.planes.range.max]
                    }
                    $0[.pipeline] = .init
                    {
                        $0.stage
                        {
                            $0[.match] = .init
                            {
                                $0[Record.Master[.stem]] = self.stem
                                $0[Record.Master[.hash]] = self.hash
                                $0[.expr] = .expr
                                {
                                    $0[.and] =
                                    (
                                        .expr
                                        {
                                            $0[.gte] = (Record.Master[.id], min)
                                        },
                                        .expr
                                        {
                                            $0[.lte] = (Record.Master[.id], max)
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
                //  Populate this field only if exactly one master record matched.
                //  This allows us to skip looking up secondary/tertiary records if
                //  we are only going to generate a disambiguation page.
                $0[.set] = .init
                {
                    $0[Output.Principal[.master]] = .expr
                    {
                        $0[.cond] =
                        (
                            if: .expr
                            {
                                $0[.eq] =
                                (
                                    1, .expr { $0[.size] = Output.Principal[.matches] }
                                )
                            },
                            then: .expr { $0[.first] = Output.Principal[.matches] },
                            else: Never??.some(nil)
                        )
                    }
                }
            }

            //  Gather all the extensions to the principal master record.
            $0.stage
            {
                $0[.lookup] = .init
                {
                    let id:Mongo.Variable<Unidoc.Scalar> = "id"
                    let min:Mongo.Variable<Unidoc.Scalar> = "min"
                    let max:Mongo.Variable<Unidoc.Scalar> = "max"

                    $0[.from] = Database.Groups.name
                    $0[.let] = .init
                    {
                        $0[let: id] = Output.Principal[.master] / Record.Master[.id]
                        $0[let: min] = Record.Zone[.planes_min]
                        $0[let: max] = Record.Zone[.planes_max]
                    }
                    $0[.pipeline] = .init
                    {
                        $0.stage
                        {
                            $0[.match] = id.groups(min: min, max: max)
                        }
                    }
                    $0[.as] = Output.Principal[.groups]
                }
            }

            //  Extract (and de-duplicate) the scalars mentioned by the extensions.
            //  Store them in this temporary field:
            let scalars:Mongo.KeyPath = "scalars"
            //  The extensions have precomputed zone ids for MongoDB’s convenience.
            let zones:Mongo.KeyPath = "zones"

            $0.stage
            {
                $0[.set] = Mongo.SetDocument.init // helps typechecking massively
                {
                    let extensions:Mongo.List<Record.Group, Mongo.KeyPath> = .init(
                        in: Output.Principal[.groups])
                    let master:Master = .init(
                        in: Output.Principal[.master])

                    $0[zones] = .expr
                    {
                        $0[.setUnion] = .init
                        {
                            $0.expr { $0[.reduce] = extensions.flatMap(\.zones) }
                            $0 += master.zones
                        }
                    }
                    $0[scalars] = .expr
                    {
                        $0[.setUnion] = .init
                        {
                            $0.expr { $0[.reduce] = extensions.flatMap(\.scalars) }
                            $0 += master.scalars
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
                                for key:Output.Principal.CodingKey in
                                        Output.Principal.CodingKey.allCases
                                {
                                    $0[Output.Principal[key]] = true
                                }
                            }
                        }
                    }
                    $0[Output[.secondary]] = .init
                    {
                        let results:Mongo.KeyPath = "results"

                        $0.stage
                        {
                            $0[.unwind] = scalars
                        }
                        $0.stage
                        {
                            $0[.match] = .init
                            {
                                $0[scalars] = .init { $0[.ne] = Never??.some(nil) }
                            }
                        }
                        $0.stage
                        {
                            $0[.lookup] = .init
                            {
                                $0[.from] = Database.Masters.name
                                $0[.localField] = scalars
                                $0[.foreignField] = Record.Master[.id]
                                $0[.as] = results
                            }
                        }
                        $0.stage
                        {
                            $0[.unwind] = results
                        }
                        $0.stage
                        {
                            $0[.replaceWith] = results
                        }
                        $0.stage
                        {
                            //  We do not need to load all the markdown for master
                            //  records in the entourage.
                            $0[.unset] = Record.Master[.details]
                        }
                    }
                    $0[Output[.zones]] = .init
                    {
                        let results:Mongo.KeyPath = "results"

                        $0.stage
                        {
                            $0[.unwind] = zones
                        }
                        $0.stage
                        {
                            $0[.match] = .init
                            {
                                $0[.and] = .init
                                {
                                    $0.append
                                    {
                                        $0[zones] = .init { $0[.ne] = .some(nil as Never?) }
                                    }
                                    $0.append
                                    {
                                        $0[zones] = .init { $0[.ne] = Record.Zone[.id] }
                                    }
                                }
                            }
                        }
                        $0.stage
                        {
                            $0[.lookup] = .init
                            {
                                $0[.from] = Database.Zones.name
                                $0[.localField] = zones
                                $0[.foreignField] = Record.Zone[.id]
                                $0[.as] = results
                            }
                        }
                        $0.stage
                        {
                            $0[.unwind] = results
                        }
                        $0.stage
                        {
                            $0[.replaceWith] = results
                        }
                    }
                }
            }
        }
    }
}

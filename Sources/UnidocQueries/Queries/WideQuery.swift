import MongoDB
import Unidoc
import UnidocDatabase
import UnidocRecords
import UnidocSelectors

@frozen public
struct WideQuery:Equatable, Hashable, Sendable
{
    public
    let mode:Selector.Lexical
    public
    let zone:Selector.Zone

    @inlinable public
    init(for mode:Selector.Lexical, in zone:Selector.Zone)
    {
        self.mode = mode
        self.zone = zone
    }
}
extension WideQuery:DatabaseQuery
{
    public
    var hint:Mongo.SortDocument { self.zone.hint }

    public
    var pipeline:Mongo.Pipeline
    {
        .init
        {
            //  This pipeline section only ever outputs one document.
            $0 += Stages.Zone<Selector.Zone>.init(self.zone,
                as: Output.Principal[.zone])

            $0.stage
            {
                $0[.lookup] = self.mode.lookup(
                    input: Output.Principal[.zone],
                    as: Output.Principal[.matches])
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

                    let topic:Mongo.Variable<Unidoc.Scalar> = "topic"
                    let min:Mongo.Variable<Unidoc.Scalar> = "min"
                    let max:Mongo.Variable<Unidoc.Scalar> = "max"

                    $0[.from] = Database.Groups.name
                    $0[.let] = .init
                    {
                        $0[let: id] = Output.Principal[.master] / Record.Master[.id]

                        $0[let: topic] = Output.Principal[.master] / Record.Master[.group]
                        $0[let: min] = Output.Principal[.zone] / Record.Zone[.planes_min]
                        $0[let: max] = Output.Principal[.zone] / Record.Zone[.planes_max]
                    }
                    $0[.pipeline] = .init
                    {
                        $0.stage
                        {
                            $0[.match] = id.groups(min: min, max: max, or: topic)
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
                $0[.set] = .init
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
            //  The `$facet` stage in ``pipeline`` should collect all records into a
            //  single document, so this pipeline should return at most 1 element.
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
                                [
                                    .matches,
                                    .master,
                                    .groups,
                                ]
                                {
                                    $0[Output.Principal[key]] = true
                                }
                                //  Do not return computed fields.
                                for key:Record.Zone.CodingKey in
                                    Record.Zone.CodingKey.independent
                                {
                                    $0[Output.Principal[.zone] / Record.Zone[key]] = true
                                }
                            }
                        }
                        $0.stage
                        {
                            $0[.lookup] = .init
                            {
                                let tree:Mongo.Variable<Unidoc.Scalar> = "tree"

                                $0[.from] = Database.Trees.name
                                $0[.let] = .init
                                {
                                    $0[let: tree] = .expr
                                    {
                                        //  ``Record.Master.Culture`` doesn’t have a `culture`
                                        //  field, but we still want to get the type tree for
                                        //  its `_id`. The ``Database.Trees`` collection only
                                        //  contains type trees, so it’s okay if the `_id` is
                                        //  not a culture.
                                        $0[.coalesce] =
                                        (
                                            Output.Principal[.master] / Record.Master[.culture],
                                            Output.Principal[.master] / Record.Master[.id]
                                        )
                                    }
                                }
                                $0[.pipeline] = .init
                                {
                                    $0.stage
                                    {
                                        $0[.match] = .init
                                        {
                                            $0[.expr] = .expr
                                            {
                                                $0[.eq] = (Record.TypeTree[.id], tree)
                                            }
                                        }
                                    }
                                }
                                $0[.as] = Output.Principal[.types]
                            }
                        }
                        $0.stage
                        {
                            //  Unbox single-element array.
                            $0[.set] = .init
                            {
                                $0[Output.Principal[.types]] = .expr
                                {
                                    $0[.first] = Output.Principal[.types]
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
                                        $0[zones] = .init
                                        {
                                            $0[.ne] =
                                                Output.Principal[.zone] / Record.Zone[.id]
                                        }
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
                        $0.stage
                        {
                            $0[.project] = .init
                            {
                                for key:Record.Zone.CodingKey in
                                        Record.Zone.CodingKey.independent
                                {
                                    $0[Record.Zone[key]] = true
                                }
                            }
                        }
                    }
                }
            }
            //  Unbox single-element arrays.
            $0.stage
            {
                $0[.set] = .init
                {
                    $0[Output[.principal]] = .expr { $0[.first] = Output[.principal] }
                }
            }
        }
    }
}

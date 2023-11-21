import MongoQL
import Unidoc
import UnidocRecords

extension Mongo.PredicateDocument
{
    /// Returns a predicate that matches all extensions to the same scope as
    /// the value of this variable, and is either from the latest version of
    /// its home package, or has an ID between the given min and max.
    static
    func groups(
        id topic:Mongo.Variable<Unidoc.Scalar>,
        or local:
        (
            scope:Mongo.Variable<Unidoc.Scalar>,
            min:Mongo.Variable<Unidoc.Scalar>,
            max:Mongo.Variable<Unidoc.Scalar>
        ),
        or global:
        (
            scope:Mongo.Variable<Unidoc.Scalar>,
            latest:Bool
        )) -> Self
    {
        .init
        {
            $0[.expr] = .expr
            {
                $0[.or] = .init
                {
                    //  FIXME: this degenerates into a full collection scan if the topic is nil.
                    $0.expr
                    {
                        $0[.eq] = (Volume.Group[.id], topic)
                    }
                    $0.expr
                    {
                        $0[.and] = .init
                        {
                            $0.expr
                            {
                                $0[.eq] = (Volume.Group[.scope], local.scope)
                            }
                            $0.expr
                            {
                                $0[.gte] = (Volume.Group[.id], local.min)
                            }
                            $0.expr
                            {
                                $0[.lte] = (Volume.Group[.id], local.max)
                            }
                        }
                    }
                    $0.expr
                    {
                        $0[.and] = .init
                        {
                            $0.expr
                            {
                                $0[.eq] = (Volume.Group[.scope], global.scope)
                            }
                            $0.expr
                            {
                                $0[.eq] = (Volume.Group[.latest], global.latest)
                            }
                        }
                    }
                }
            }
        }
    }
}

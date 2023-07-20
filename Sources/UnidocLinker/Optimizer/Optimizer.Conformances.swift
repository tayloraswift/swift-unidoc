import Signatures
import Unidoc

extension Optimizer
{
    struct Conformances:Sendable
    {
        private
        var signatures:[Unidoc.Scalar: [ConformanceSignature]]

        private
        init(signatures:[Unidoc.Scalar: [ConformanceSignature]])
        {
            self.signatures = signatures
        }
    }
}
extension Optimizer.Conformances:ExpressibleByDictionaryLiteral
{
    init(dictionaryLiteral:(Unidoc.Scalar, Never)...)
    {
        self.init(signatures: [:])
    }
}
extension Optimizer.Conformances
{
    subscript(to protocol:Unidoc.Scalar) -> [Optimizer.ConformanceSignature]
    {
        _read
        {
            yield  self.signatures[`protocol`, default: []]
        }
        _modify
        {
            yield &self.signatures[`protocol`, default: []]
        }
    }
}
extension Optimizer.Conformances:Sequence
{
    func makeIterator() -> Iterator
    {
        .init(self.signatures.makeIterator())
    }
}
extension Optimizer.Conformances
{
    mutating
    func reduce(with context:DynamicContext, errors:inout [any DynamicLinkerError])
    {
        self.signatures = self.signatures.mapValues
        {
            //  Group conformances to this protocol by culture.
            let segregated:[Unidoc.Scalar: [[GenericConstraint<Unidoc.Scalar?>]]] = $0.reduce(
                into: [:])
            {
                $0[$1.culture, default: []].append($1.conditions)
            }

            //  A type can only conform to a protocol once in a culture,
            //  so we need to pick the most general set of generic constraints.
            //
            //  For example, `Optional<T>` conforms to `Equatable` where
            //  `T:Equatable`, but it also conforms to `Equatable` where
            //  `T:Hashable`, because if `T` is ``Hashable`` then it is also
            //  ``Equatable``. So that conformance is redundant.
            let reduced:[Unidoc.Scalar: [GenericConstraint<Unidoc.Scalar?>]] =
                segregated.mapValues
            {
                //  Swift does not have conditional disjunctions for protocol
                //  conformances. So the most general constraint list must be
                //  (one of) the shortest.
                var shortest:[[GenericConstraint<Unidoc.Scalar?>]] = []
                var length:Int = .max
                for constraints:[GenericConstraint<Unidoc.Scalar?>] in $0
                {
                    if      constraints.count <  length
                    {
                        shortest = [constraints]
                        length = constraints.count
                    }
                    else if constraints.count == length
                    {
                        shortest.append(constraints)
                    }
                }
                //  The array is always non-empty because `$0` itself is always
                //  non-empty, because it was created by appending to
                //  ``Dictionary.subscript(_:default:)``.
                if  shortest.count == 1
                {
                    return shortest[0]
                }

                let constraints:Set<GenericConstraint<Unidoc.Scalar?>> = .init(
                    shortest.joined())
                let reduced:Set<GenericConstraint<Unidoc.Scalar?>> = constraints.filter
                {
                    switch $0
                    {
                    case .where(_,             is: .equal,   to: _):
                        //  Same-type constraints are never redundant.
                        break

                    case .where(let parameter, is: let what, to: let type):
                        if  case .nominal(let type?) = type,
                            let snapshot:SnapshotObject = context[type.package],
                            let local:[Int32] = snapshot.nodes[type]?.decl?.superforms
                        {
                            for local:Int32 in local
                            {
                                //  If the constraint is `T:Hashable`, `Hashable:Equatable`,
                                //  and `T:Equatable` exists in the constraint set, then this
                                //  constraint is redundant.
                                if  let supertype:Unidoc.Scalar = snapshot.scalars[local],
                                        supertype != type,
                                        constraints.contains(.where(parameter,
                                            is: what,
                                            to: .nominal(supertype)))
                                {
                                    return false
                                }
                            }
                        }
                    }

                    return true
                }
                //  We shouldn’t have fewer total constraints than we started with,
                //  otherwise that means some of the constraint lists had redundancies
                //  within themselves, and the Swift compiler should have already
                //  removed those.
                //
                //  By the same reasoning, at least one of the constraint lists should
                //  contain exactly the same constraints as the reduced set. We don’t
                //  return the set itself, because this implementation does not know
                //  anything about canonical constraint ordering.
                let ordered:[[GenericConstraint<Unidoc.Scalar?>]] = shortest.filter
                {
                    $0.allSatisfy(reduced.contains(_:))
                }
                if  ordered.count == 1
                {
                    return ordered[0]
                }
                else
                {
                    errors.append(ConstraintReductionError.init(invalid: ordered,
                        minimal: .init(reduced)))
                    //  See note above about non-emptiness.
                    return shortest.first!
                }
            }

            //  Conformances should now be unique per culture.
            return reduced.map
            {
                .init(conditions: $0.value, culture: $0.key)
            }
            .sorted
            {
                $0.culture < $1.culture
            }
        }
    }
}

import ModuleGraphs
import Signatures
import SymbolGraphs
import Unidoc
import UnidocDiagnostics

struct ProtocolConformances<Culture>
{
    private
    var table:[Unidoc.Scalar: [ProtocolConformance<Culture>]]

    private
    init(table:[Unidoc.Scalar: [ProtocolConformance<Culture>]])
    {
        self.table = table
    }
}
extension ProtocolConformances:Sendable where Culture:Sendable
{
}
extension ProtocolConformances
{
    subscript(to protocol:Unidoc.Scalar) -> [ProtocolConformance<Culture>]
    {
        _read
        {
            yield  self.table[`protocol`, default: []]
        }
        _modify
        {
            yield &self.table[`protocol`, default: []]
        }
    }
}
extension ProtocolConformances:Sequence
{
    func makeIterator() -> Iterator
    {
        .init(self.table.makeIterator())
    }
}
extension ProtocolConformances:ExpressibleByDictionaryLiteral
{
    init(dictionaryLiteral elements:(Unidoc.Scalar, Never)...)
    {
        self.init(table: [:])
    }
}
extension ProtocolConformances<Int>
{
    init(context:DynamicContext,
        diagnostics:inout DiagnosticContext<DynamicSymbolicator>,
        with populate:(inout ProtocolConformances<Int>) throws -> Void) rethrows
    {
        var conformances:ProtocolConformances<Int> = [:]
        try populate(&conformances)
        let deduplicated:[Unidoc.Scalar: [ProtocolConformance<Int>]] =
            conformances.table.mapValues
        {
            /// The set of local package cultures in which this protocol conformance
            /// exists, either conditionally or unconditionally.
            ///
            /// It is valid (but totally demented) for a package to declare the same
            /// conformance in multiple modules, as long as they never intersect in
            /// a build tree.
            let extancy:Set<Int> = $0.reduce(into: []) { $0.insert($1.culture) }

            //  Group conformances to this protocol by culture.
            let segregated:[Int: [[GenericConstraint<Unidoc.Scalar?>]]] = $0.reduce(
                into: [:])
            {
                let module:ModuleDetails = context.current.cultures[$1.culture].module
                for c:Int in module.dependencies.modules where
                    c != $1.culture && extancy.contains(c)
                {
                    //  Another module in this package already declares this
                    //  conformance, and the `$1.culture` depends on it!
                    return
                }

                $0[$1.culture, default: []].append($1.conditions)
            }

            //  A type can only conform to a protocol once in a culture,
            //  so we need to pick the most general set of generic constraints.
            //
            //  For example, `Optional<T>` conforms to `Equatable` where
            //  `T:Equatable`, but it also conforms to `Equatable` where
            //  `T:Hashable`, because if `T` is ``Hashable`` then it is also
            //  ``Equatable``. So that conformance is redundant.
            let reduced:[Int: [GenericConstraint<Unidoc.Scalar?>]] =
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
                            let local:[Int32] = snapshot.decls[type.citizen]?.decl?.superforms
                        {
                            for local:Int32 in local
                            {
                                //  If the constraint is `T:Hashable`, `Hashable:Equatable`,
                                //  and `T:Equatable` exists in the constraint set, then this
                                //  constraint is redundant.
                                if  let supertype:Unidoc.Scalar = snapshot.scalars.decls[local],
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
                    diagnostics[nil] = ConstraintReductionError.init(invalid: ordered,
                        minimal: .init(reduced))
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

        self.init(table: deduplicated)
    }
}

import Signatures
import Symbols

extension Set<Set<GenericConstraint<Symbol.Decl>>>
{
    mutating
    func simplify(
        with declarations:SSGC.Declarations) throws -> Set<GenericConstraint<Symbol.Decl>>
    {
        guard
        var first:Set<GenericConstraint<Symbol.Decl>> = self.first
        else
        {
            return []
        }

        if  self.count == 1
        {
            return first
        }
        else
        {
            first = try self.simplified(with: declarations)
        }

        //  Cache the simplified constraints so that the next query is faster.
        self = [first]
        return first
    }

    private
    func simplified(
        with declarations:SSGC.Declarations) throws -> Set<GenericConstraint<Symbol.Decl>>
    {
        //  Swift does not have conditional disjunctions for protocol
        //  conformances. So the most general constraint list must be
        //  (one of) the shortest.
        var length:Int = .max
        let shortest:[Set<GenericConstraint<Symbol.Decl>>] = self.reduce(into: [])
        {
            if  $1.count < length
            {
                length = $1.count
                $0 = [$1]
            }
            else if $1.count == length
            {
                $0.append($1)
            }
        }
        //  The array is always non-empty because `$0` itself is always
        //  non-empty, because it was created by appending to
        //  ``Dictionary.subscript(_:default:)``.
        if  shortest.count == 1
        {
            return shortest[0]
        }

        let all:Set<GenericConstraint<Symbol.Decl>> = .init(shortest.joined())
        let reduced:Set<GenericConstraint<Symbol.Decl>> = try all.filter
        {
            switch $0
            {
            case .where(_, is: .equal, to: _):
                //  Same-type constraints are never redundant.
                return true

            case .where(let parameter, is: let what, to: let type):
                if  let type:Symbol.Decl = type.nominal
                {
                    let decl:SSGC.Decl = try declarations[type].value
                    for supertype:Symbol.Decl in decl.superforms where supertype != type
                    {
                        //  If the weaker constraint exists in the set of all constraints, then
                        //  this constraint is redundant.
                        //
                        //  For example, if the constraint is `T:Hashable`,
                        //  `Hashable:Equatable`, and `T:Equatable` exists in the constraint
                        //  set, then the constraint is redundant.
                        for case .where(parameter, is: what, to: let target) in all
                        {
                            if  case supertype? = target.nominal
                            {
                                return false
                            }
                        }
                    }
                }
                return true
            }
        }
        //  We shouldn’t have fewer total constraints than we started with,
        //  otherwise that means some of the constraint lists had redundancies
        //  within themselves, and the Swift compiler should have already
        //  removed those.
        guard reduced.count == length
        else
        {
            throw SSGC.ConstraintReductionError.redundant(reduced, from: shortest)
        }
        //  By the same reasoning, at least one of the constraint lists should
        //  contain exactly the same constraints as the reduced set. We don’t
        //  return the set itself, because this implementation does not know
        //  anything about canonical constraint ordering.
        guard shortest.contains(reduced)
        else
        {
            throw SSGC.ConstraintReductionError.chimaeric(reduced, from: shortest)
        }

        return reduced
    }
}

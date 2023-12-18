import Signatures
import Unidoc

extension Unidoc
{
    struct EditionSet:Equatable, Sendable
    {
        private(set)
        var ordered:[Edition]
        private
        var seen:Set<Edition>

        private
        init(ordered:[Edition], seen:Set<Edition>)
        {
            self.ordered = ordered
            self.seen = seen
        }
    }
}
extension Unidoc.EditionSet
{
    init(except exclude:Unidoc.Edition? = nil)
    {
        self.init(ordered: [], seen: exclude.map { [$0] } ?? [])
    }
}
extension Unidoc.EditionSet
{
    mutating
    func update(with zone:Unidoc.Edition)
    {
        if  case nil = self.seen.update(with: zone)
        {
            self.ordered.append(zone)
        }
    }
}
extension Unidoc.EditionSet
{
    mutating
    func update(with zone:Unidoc.Edition?)
    {
        if  let zone:Unidoc.Edition = zone
        {
            self.update(with: zone)
        }
    }
    mutating
    func update(with scalars:[Unidoc.Scalar])
    {
        for scalar:Unidoc.Scalar in scalars
        {
            self.update(with: scalar.edition)
        }
    }
    mutating
    func update(with scalars:[Unidoc.Scalar?])
    {
        for scalar:Unidoc.Scalar? in scalars
        {
            self.update(with: scalar?.edition)
        }
    }
    mutating
    func update(with constraints:[GenericConstraint<Unidoc.Scalar?>])
    {
        for constraint:GenericConstraint<Unidoc.Scalar?> in constraints
        {
            self.update(with: constraint.whom.nominal??.edition)
        }
    }
    mutating
    func update(with outlines:[Unidoc.Outline])
    {
        for case .path(_, let scalars) in outlines
        {
            self.update(with: scalars)
        }
    }
}

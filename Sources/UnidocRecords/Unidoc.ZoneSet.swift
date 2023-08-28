import Signatures
import Unidoc

extension Unidoc
{
    struct ZoneSet:Equatable, Sendable
    {
        private(set)
        var ordered:[Zone]
        private
        var seen:Set<Zone>

        private
        init(ordered:[Zone], seen:Set<Zone>)
        {
            self.ordered = ordered
            self.seen = seen
        }
    }
}
extension Unidoc.ZoneSet
{
    init(except exclude:Unidoc.Zone? = nil)
    {
        self.init(ordered: [], seen: exclude.map { [$0] } ?? [])
    }
}
extension Unidoc.ZoneSet
{
    mutating
    func update(with zone:Unidoc.Zone)
    {
        if  case nil = self.seen.update(with: zone)
        {
            self.ordered.append(zone)
        }
    }
}
extension Unidoc.ZoneSet
{
    mutating
    func update(with zone:Unidoc.Zone?)
    {
        if  let zone:Unidoc.Zone = zone
        {
            self.update(with: zone)
        }
    }
    mutating
    func update(with scalars:[Unidoc.Scalar])
    {
        for scalar:Unidoc.Scalar in scalars
        {
            self.update(with: scalar.zone)
        }
    }
    mutating
    func update(with scalars:[Unidoc.Scalar?])
    {
        for scalar:Unidoc.Scalar? in scalars
        {
            self.update(with: scalar?.zone)
        }
    }
    mutating
    func update(with constraints:[GenericConstraint<Unidoc.Scalar?>])
    {
        for constraint:GenericConstraint<Unidoc.Scalar?> in constraints
        {
            self.update(with: constraint.whom.nominal??.zone)
        }
    }
    mutating
    func update(with outlines:[Volume.Outline])
    {
        for case .path(_, let scalars) in outlines
        {
            self.update(with: scalars)
        }
    }
}

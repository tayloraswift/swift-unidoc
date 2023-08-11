import Signatures
import Unidoc
import UnidocRecords

extension Inliner.Groups
{
    struct Generics
    {
        private
        let parameters:Set<String>

        private
        init(parameters:Set<String>)
        {
            self.parameters = parameters
        }
    }
}
extension Inliner.Groups.Generics
{
    init(_ generics:__shared [GenericParameter])
    {
        self.init(parameters: generics.reduce(into: []) { $0.insert($1.name) })
    }

    /// Partitions the given extensions into concrete and generic extensions.
    /// The output contains the concrete extensions first, sorted by culture,
    /// then the generic extensions, sorted by culture. Cultures sort by
    /// dependency graph order, not alphabetically.
    func partition(extensions:__shared [Record.Group.Extension]) -> [Record.Group.Extension]
    {
        var concrete:[Record.Group.Extension] = []
        var generic:[Record.Group.Extension] = []

        for `extension`:Record.Group.Extension in extensions
        {
            var substituted:Int = 0
            for constraint:GenericConstraint<Unidoc.Scalar?> in `extension`.conditions
            {
                if  case .equal = constraint.what, self.parameters.contains(constraint.noun)
                {
                    substituted += 1
                }
            }
            if  substituted == self.parameters.count
            {
                concrete.append(`extension`)
            }
            else
            {
                generic.append(`extension`)
            }
        }

        concrete.sort { $0.culture.citizen < $1.culture.citizen }
        generic.sort { $0.culture.citizen < $1.culture.citizen }

        return concrete + generic
    }
}

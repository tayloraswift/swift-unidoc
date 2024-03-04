import Signatures
import Unidoc
import UnidocRecords

extension Swiftinit.Mesh.Halo
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
extension Swiftinit.Mesh.Halo.Generics
{
    init(_ generics:__shared [GenericParameter])
    {
        self.init(parameters: generics.reduce(into: []) { $0.insert($1.name) })
    }

    var count:Int { self.parameters.count }

    /// Returns the number of free generic parameters remaining after applying any same-type
    /// constraints in the given list.
    func count(substituting constraints:[GenericConstraint<Unidoc.Scalar?>]) -> Int
    {
        var count:Int = self.parameters.count
        for constraint:GenericConstraint<Unidoc.Scalar?> in constraints
        {
            if  case .equal = constraint.what, self.parameters.contains(constraint.noun)
            {
                count -= 1
            }
        }
        return max(0, count)
    }
}

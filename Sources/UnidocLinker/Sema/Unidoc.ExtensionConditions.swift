import Signatures
import Unidoc

extension Unidoc
{
    struct ExtensionConditions:Equatable, Hashable, Sendable
    {
        var constraints:[GenericConstraint<Unidoc.Scalar?>]
        let culture:Int

        init(constraints:[GenericConstraint<Unidoc.Scalar?>], culture:Int)
        {
            self.constraints = constraints
            self.culture = culture
        }
    }
}

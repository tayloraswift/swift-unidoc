import Signatures
import Unidoc

extension Unidoc.Linker
{
    struct ExtensionConditions:Equatable, Hashable, Sendable
    {
        let constraints:[GenericConstraint<Unidoc.Scalar?>]
        let culture:Int

        init(constraints:[GenericConstraint<Unidoc.Scalar?>], culture:Int)
        {
            self.constraints = constraints
            self.culture = culture
        }
    }
}

import SymbolGraphs
import Unidoc

extension Optimizer
{
    struct Extension
    {
        private(set)
        var conformances:Set<Unidoc.Scalar>
        private(set)
        var features:Set<Unidoc.Scalar>
        private(set)
        var nested:Set<Unidoc.Scalar>

        init()
        {
            self.conformances = []
            self.features = []
            self.nested = []
        }
    }
}
extension Optimizer.Extension
{
    mutating
    func update(with `extension`:SymbolGraph.Extension,
        by decls:SymbolGraph.Plane<UnidocPlane.Decl, Unidoc.Scalar?>)
    {
        for conformance:Int32 in `extension`.conformances
        {
            if  let conformance:Unidoc.Scalar = decls[conformance]
            {
                self.conformances.update(with: conformance)
            }
        }
        for feature:Int32 in `extension`.features
        {
            if  let feature:Unidoc.Scalar = decls[feature]
            {
                self.features.update(with: feature)
            }
        }
        for nested:Int32 in `extension`.nested
        {
            if  let nested:Unidoc.Scalar = decls[nested]
            {
                self.nested.update(with: nested)
            }
        }
    }
}

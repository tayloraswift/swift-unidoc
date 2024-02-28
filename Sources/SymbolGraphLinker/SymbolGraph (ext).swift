import FNV1
import InlineArray
import InlineDictionary
import SourceDiagnostics
import SymbolGraphs

extension SymbolGraph
{
    mutating
    func colorize(routes:[SSGC.Route: InlineDictionary<FNV24?, InlineArray<Int32>>],
        with diagnostics:inout Diagnostics<SSGC.Symbolicator>)
    {
        for n:Int32 in self.decls.nodes.indices
        {
            let propogate:Bool =
            {
                guard
                var decl:SymbolGraph.Decl = $0
                else
                {
                    return false
                }
                //  It would be nice if lib/SymbolGraphGen told us about the
                //  `@_documentation(visibility:)` attribute. But it does not.
                guard
                case "_"? = decl.path.last.first
                else
                {
                    return false
                }

                decl.route.underscored = true
                $0 = decl

                //  Declarations only propagate underscoredness if their children could not
                //  possibly be inherited by a different declaration.
                switch decl.phylum
                {
                case .actor:            return true    // Actors are always final.
                case .associatedtype:   return false   // Cannot have children.
                case .case:             return false   // Cannot have children.
                case .class:            return decl.kinks[is: .final]
                case .deinitializer:    return false   // Cannot have children.
                case .enum:             return true
                case .func:             return false   // Cannot have children.
                case .initializer:      return false   // Cannot have children.
                case .macro:            return false   // Cannot have children.
                case .operator:         return false   // Cannot have children.
                case .protocol:         return false   // Protocols are never final by nature.
                case .struct:           return true
                case .subscript:        return false   // Cannot have children.
                case .typealias:        return false   // Cannot have children.
                case .var:              return false   // Cannot have children.
                }

            } (&self.decls.nodes[n].decl)

            guard propogate
            else
            {
                continue
            }

            for `extension`:SymbolGraph.Extension in self.decls.nodes[n].extensions
            {
                for n:Int32 in `extension`.nested where
                    self.decls.nodes.indices.contains(n)
                {
                    self.decls.nodes[n].decl?.route.underscored = true
                }
            }
        }

        for case (let path, .some(let members)) in routes
        {
            for (hash, addresses):(FNV24?, InlineArray<Int32>) in members
            {
                if  let hash:FNV24
                {
                    for stacked:Int32 in addresses
                    {
                        //  If `hash` is present, then we know the decl is a valid
                        //  declaration node index.
                        self.decls.nodes[stacked].decl?.route.hashed = true
                    }
                    guard
                    case .some(let collisions) = addresses
                    else
                    {
                        continue
                    }

                    diagnostics[nil] = SSGC.RouteCollisionError.hash(hash, collisions)
                }
                else
                {
                    let collisions:[Int32] =
                    switch addresses
                    {
                    case .one(let scalar):  [scalar]
                    case .some(let scalars): scalars
                    }

                    diagnostics[nil] = SSGC.RouteCollisionError.path(path, collisions)
                }
            }
        }
    }
}

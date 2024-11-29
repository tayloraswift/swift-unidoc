import SymbolGraphs
import Unidoc
import UnidocRecords

extension WritableKeyPath<Unidoc.Stats.Coverage, Int>
{
    //  TODO: This is a temporary solution. This statistic should not depend on the snapshot.
    //  Ideally, we should reformulate the scoring system to assign a “expected” amount of
    //  documentation for each declaration, which does not depend on other declarations.
    static
    func classify(_ decl:SymbolGraph.Decl,
        _from snapshot:Unidoc.LinkableGraph,
        _at local:Int32) -> WritableKeyPath<Unidoc.Stats.Coverage, Int>
    {
        if  case _? = decl.article
        {
            return \.direct
        }
        if  case _? = decl.origin
        {
            return \.indirect
        }
        //  We only count indirect documentation from a lexical scope if the decl is not itself
        //  a scope, and its scope was declared and documented in the same package.
        switch decl.phylum
        {
        case    .actor, .class, .enum, .protocol, .struct, .macro:
            return \.undocumented

        case    .associatedtype,
                .case,
                .deinitializer,
                .func,
                .initializer,
                .operator,
                .subscript,
                .typealias,
                .var:
            break
        }

        if  let scope:Unidoc.Scalar = snapshot.scope(of: local),
            let scope:Int32 = scope - snapshot.id,
            case _? = snapshot.decls[scope]?.decl?.article
        {
            return \.indirect
        }
        else
        {
            return \.undocumented
        }
    }
}
extension WritableKeyPath<Unidoc.Stats.Decl, Int>
{
    static
    func classify(_ decl:SymbolGraph.Decl) -> WritableKeyPath<Unidoc.Stats.Decl, Int>
    {
        if  decl.kinks[is: .required]
        {
            return \.requirements
        }
        if  decl.kinks[is: .intrinsicWitness]
        {
            return \.witnesses
        }
        if  case .func(.instance?) = decl.phylum,
            decl.path.last.prefix(while: { $0 != "(" }) == "callAsFunction"
        {
            return \.functors
        }

        switch decl.phylum
        {
        case    .associatedtype:        return \.requirements
        case    .typealias:             return \.typealiases
        case    .struct,
                .enum:                  return \.structures
        case    .protocol:              return \.protocols
        case    .class:                 return \.classes
        case    .actor:                 return \.actors
        case    .initializer,
                .subscript(.static),
                .subscript(.class),
                .func(.static?),
                .func(.class?),
                .var(.static?),
                .var(.class?),
                .case:                  return \.constructors
        case    .subscript(.instance):  return \.subscripts
        case    .deinitializer,
                .func(.instance?),
                .var(.instance?):       return \.methods
        case    .operator:              return \.operators
        case    .func(nil),
                .var(nil):              return \.functions
        case    .macro(.freestanding):  return \.freestandingMacros
        case    .macro(.attached):      return \.attachedMacros
        }
    }
}

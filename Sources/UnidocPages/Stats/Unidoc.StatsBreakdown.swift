import HTML
import Unidoc
import UnidocRecords

extension Unidoc
{
    struct StatsBreakdown
    {
        private
        var unweighted:Pie<Stat>
        private
        var weighted:Pie<Stat>

        private
        init(unweighted:Pie<Stat> = [], weighted:Pie<Stat> = [])
        {
            self.unweighted = unweighted
            self.weighted = weighted
        }
    }
}
extension Unidoc.StatsBreakdown
{
    private
    init<Stats>(
        unweighted:__shared Stats,
        weighted:__shared Stats,
        domain:__shared String,
        _ keys:KeyPath<Stats, Int>...,
        class:(KeyPath<Stats, Int>) -> String?,
        prose:(KeyPath<Stats, Int>) -> String?)
    {
        self.init()

        for key:KeyPath<Stats, Int> in keys
        {
            let unweighted:Int = unweighted[keyPath: key]
            if  unweighted > 0
            {
                self.unweighted.append(.init(
                    stratum: "declarations in \(domain)",
                    state: prose(key) ?? "?",
                    value: unweighted,
                    class: `class`(key)))
            }

            let weighted:Int = weighted[keyPath: key]
            if  weighted > 0
            {
                self.weighted.append(.init(
                    stratum: "symbols in \(domain)",
                    state: prose(key) ?? "?",
                    value: weighted,
                    class: `class`(key)))
            }
        }
    }

    init(
        unweighted:__shared Volume.Stats.Coverage,
        weighted:__shared Volume.Stats.Coverage,
        domain:__shared String)
    {
        self.init(
            unweighted: unweighted,
            weighted: weighted,
            domain: domain,
            \.direct,
            \.indirect,
            \.undocumented)
        {
            switch $0
            {
            case \.direct:          return "coverage direct"
            case \.indirect:        return "coverage indirect"
            case \.undocumented:    return "coverage undocumented"
            case _:                 return nil
            }
        }
            prose:
        {
            switch $0
            {
            case \.direct:          return "fully documented"
            case \.indirect:        return "indirectly documented"
            case \.undocumented:    return "completely undocumented"
            case _:                 return nil
            }
        }
    }

    init(
        unweighted:__shared Volume.Stats.Decl,
        weighted:__shared Volume.Stats.Decl,
        domain:__shared String)
    {
        self.init(
            unweighted: unweighted,
            weighted: weighted,
            domain: domain,
            \.functions,
            \.operators,
            \.constructors,
            \.methods,
            \.subscripts,
            \.functors,
            \.protocols,
            \.requirements,
            \.witnesses,
            \.structures,
            \.classes,
            \.actors,
            \.typealiases)
        {
            switch $0
            {
            case \.functions:       return "decl function"
            case \.operators:       return "decl operator"
            case \.constructors:    return "decl constructor"
            case \.methods:         return "decl method"
            case \.subscripts:      return "decl subscript"
            case \.functors:        return "decl functor"
            case \.protocols:       return "decl protocol"
            case \.requirements:    return "decl requirement"
            case \.witnesses:       return "decl witness"
            case \.structures:      return "decl structure"
            case \.classes:         return "decl class"
            case \.actors:          return "decl actor"
            case \.typealiases:     return "decl typealias"
            case _:                 return nil
            }
        }
            prose:
        {
            switch $0
            {
            case \.functions:       return "global functions or variables"
            case \.operators:       return "operators"
            case \.constructors:    return "initializers, type members, or enum cases"
            case \.methods:         return "instance members"
            case \.subscripts:      return "instance subscripts"
            case \.functors:        return "functors"
            case \.protocols:       return "protocols"
            case \.requirements:    return "protocol requirements"
            case \.witnesses:       return "default implementations"
            case \.structures:      return "structures"
            case \.classes:         return "classes"
            case \.actors:          return "actors"
            case \.typealiases:     return "typealiases"
            case _:                 return nil
            }
        }
    }
}
extension Unidoc.StatsBreakdown
{
    var condensed:Condensed
    {
        .init(unweighted: self.unweighted, weighted: self.weighted)
    }
}
extension Unidoc.StatsBreakdown:HyperTextOutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.h3] = "Declarations"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.unweighted
            $0[.figcaption] { $0[.dl] = self.unweighted.legend }
        }

        html[.h3] = "Symbols"
        html[.figure, { $0.class = "chart" }]
        {
            $0[.div] { $0.class = "pie" } = self.weighted
            $0[.figcaption] { $0[.dl] = self.weighted.legend }
        }
    }
}

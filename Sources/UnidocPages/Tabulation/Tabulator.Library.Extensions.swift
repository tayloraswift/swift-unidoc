import Signatures
import Unidoc
import UnidocRecords

extension Tabulator.Library
{
    struct Extensions
    {
        private(set)
        var concrete:[Record.Group.Extension]
        private(set)
        var generic:[Record.Group.Extension]

        private
        init(concrete:[Record.Group.Extension] = [], generic:[Record.Group.Extension] = [])
        {
            self.concrete = concrete
            self.generic = generic
        }
    }
}
extension Tabulator.Library.Extensions
{
    init(
        partitioning extensions:__shared [Record.Group.Extension],
        generics:__shared [GenericParameter])
    {
        self.init()

        let generics:Set<String> = generics.reduce(into: []) { $0.insert($1.name) }
        for `extension`:Record.Group.Extension in extensions
        {
            var substituted:Int = 0
            for constraint:GenericConstraint<Unidoc.Scalar?> in `extension`.conditions
            {
                if  case .equal = constraint.what, generics.contains(constraint.noun)
                {
                    substituted += 1
                }
            }
            if  substituted == generics.count
            {
                self.concrete.append(`extension`)
            }
            else
            {
                self.generic.append(`extension`)
            }
        }

        self.concrete.sort { $0.culture.citizen < $1.culture.citizen }
        self.generic.sort { $0.culture.citizen < $1.culture.citizen }
    }
}

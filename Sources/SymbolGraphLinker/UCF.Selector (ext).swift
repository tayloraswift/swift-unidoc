import FNV1
import UCF

extension UCF.Selector
{
    func ignore(when definitions:[String: Void]) throws -> Bool
    {
        guard
        case .unidoc(let disambiguator)? = self.suffix
        else
        {
            return false
        }

        for condition:UCF.ConditionFilter in disambiguator.conditions
        {
            if  case .ignore_when = condition.label,
                definitions.keys.contains(try condition.value())
            {
                return true
            }
        }

        return false
    }

    func with(hash:FNV24) -> UCF.Selector
    {
        .init(base: self.base, path: self.path, suffix: .hash(hash))
    }
}

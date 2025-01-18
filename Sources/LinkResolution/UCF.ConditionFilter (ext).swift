import UCF

extension UCF.ConditionFilter
{
    @inlinable public
    func value<T>(as _:T.Type = T.self) throws -> T where T:LosslessStringConvertible
    {
        guard
        let value:String = self.value
        else
        {
            throw UCF.ConditionError.valueExpected(self.label)
        }

        guard
        let result:T = .init(value)
        else
        {
            throw UCF.ConditionError.value(self.label, value)
        }

        return result
    }

    func callAsFunction<T>(as _:T.Type = T.self,
        default:T) throws -> (UCF.Condition, T) where T:LosslessStringConvertible
    {
        guard
        let value:String = self.value
        else
        {
            return (self.label, `default`)
        }

        guard
        let result:T = .init(value)
        else
        {
            throw UCF.ConditionError.value(self.label, value)
        }

        return (self.label, result)
    }
}

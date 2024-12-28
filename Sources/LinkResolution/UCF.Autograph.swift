import UCF

extension UCF
{
    @frozen public
    struct Autograph:Equatable, Sendable
    {
        public
        let inputs:[String]
        public
        let output:[String]

        @inlinable public
        init(inputs:[String], output:[String])
        {
            self.inputs = inputs
            self.output = output
        }
    }
}
extension UCF.Autograph
{
    static func ~= (filter:UCF.SignatureFilter, self:Self) -> Bool
    {
        if  let inputs:[String?] = filter.inputs
        {
            guard self.inputs.count == inputs.count
            else
            {
                return false
            }
            for case (let required, let provided?) in zip(self.inputs, inputs)
            {
                if  required != provided
                {
                    return false
                }
            }
        }

        if  let output:[String?] = filter.output
        {
            guard self.output.count == output.count
            else
            {
                return false
            }
            for case (let required, let provided?) in zip(self.output, output)
            {
                if  required != provided
                {
                    return false
                }
            }
        }

        return true
    }
}

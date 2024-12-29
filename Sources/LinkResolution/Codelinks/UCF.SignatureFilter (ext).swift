import UCF

extension UCF.SignatureFilter
{
    static func ~= (self:Self, autograph:UCF.Autograph) -> Bool
    {
        if  let inputs:[String?] = self.inputs
        {
            guard autograph.inputs.count == inputs.count
            else
            {
                return false
            }
            for case (let required, let provided?) in zip(autograph.inputs, inputs)
            {
                if  required != provided
                {
                    return false
                }
            }
        }

        if  let output:[String?] = self.output
        {
            guard autograph.output.count == output.count
            else
            {
                return false
            }
            for case (let required, let provided?) in zip(autograph.output, output)
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

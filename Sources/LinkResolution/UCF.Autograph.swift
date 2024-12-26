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
    static func ~= (predicate:UCF.PatternFilter, self:Self) -> Bool
    {
        if  let inputs:[String?] = predicate.inputs
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

        switch predicate.output
        {
        case nil:
            break

        case .single(let output):
            guard self.output.count == 1
            else
            {
                return false
            }

            if  let output:String, output != self.output[0]
            {
                return false
            }

        case .tuple(let outputs):
            guard self.output.count == outputs.count
            else
            {
                return false
            }
            for case (let required, let provided?) in zip(self.output, outputs)
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

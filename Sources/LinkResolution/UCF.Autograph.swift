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

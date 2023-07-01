extension Record.Stem
{
    @frozen public
    struct Last:Equatable, Hashable, Sendable
    {
        public
        let separator:Unicode.Scalar
        public
        let component:String

        @inlinable public
        init(separator:Unicode.Scalar, component:String)
        {
            self.separator = separator
            self.component = component
        }
    }
}

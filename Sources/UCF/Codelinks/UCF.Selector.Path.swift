extension UCF.Selector
{
    @frozen public
    struct Path:Equatable, Hashable, Sendable
    {
        /// The individual components of this path.
        public
        var components:[String]
        /// The index of the first visible component in this path.
        public
        var fold:Int
        public
        var seal:Seal?

        @inlinable public
        init(components:[String] = [], fold:Int = 0, seal:Seal? = nil)
        {
            self.components = components
            self.fold = fold
            self.seal = seal
        }
    }
}
extension UCF.Selector.Path
{
    @inlinable public
    var hasTrailingParentheses:Bool
    {
        self.seal != nil
    }

    @inlinable public
    var visible:ArraySlice<String>
    {
        self.components[self.fold...]
    }
}
extension UCF.Selector.Path
{
    mutating
    func append(_ component:UCF.Selector.PathComponent)
    {
        self.components.append(component.value)
        self.seal = component.seal
    }
}

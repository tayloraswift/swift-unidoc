extension Unidoc
{
    @frozen public
    struct LinkTarget
    {
        /// Nil if the link target points back to the current page.
        public
        let location:String?

        @inlinable public
        init(location:String?)
        {
            self.location = location
        }
    }
}

extension Unidoc
{
    @frozen public
    struct GraphPath
    {
        public
        let edition:Unidoc.Edition
        public
        let type:Unidoc.GraphType

        @inlinable public
        init(edition:Unidoc.Edition, type:Unidoc.GraphType)
        {
            self.edition = edition
            self.type = type
        }
    }
}
extension Unidoc.GraphPath:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        """
        /graphs/\
        \(String.init(self.edition.package.bits, radix: 16))/\
        \(String.init(self.edition.version.bits, radix: 16)).\(self.type)
        """
    }
}

extension CodelinkV4
{
    @frozen public
    struct Path:Equatable, Hashable, Sendable
    {
        public
        var components:[String]
        public
        var visible:Int
    }
}

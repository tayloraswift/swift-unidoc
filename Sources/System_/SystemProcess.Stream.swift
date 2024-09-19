extension SystemProcess
{
    @frozen public
    struct Stream
    {
        @usableFromInline
        let parent:FileDescriptor
        @usableFromInline
        let child:Int32

        @inlinable
        init(parent:FileDescriptor, child:Int32)
        {
            self.parent = parent
            self.child = child
        }
    }
}

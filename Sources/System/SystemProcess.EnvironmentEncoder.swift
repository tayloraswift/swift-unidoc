extension SystemProcess
{
    @frozen public
    struct EnvironmentEncoder
    {
        @usableFromInline
        var offsets:[Int]
        @usableFromInline
        var buffer:[UInt8]

        @inlinable
        init()
        {
            self.offsets = []
            self.buffer = []
        }
    }
}
extension SystemProcess.EnvironmentEncoder
{
    @inlinable public
    subscript(name:String) -> String?
    {
        get { nil }
        set (value)
        {
            guard
            let value:String
            else
            {
                return
            }

            self.offsets.append(self.buffer.count)
            self.buffer += name.utf8
            self.buffer.append(0x3D) // '='
            self.buffer += value.utf8
            self.buffer.append(0x00)
        }
    }
}

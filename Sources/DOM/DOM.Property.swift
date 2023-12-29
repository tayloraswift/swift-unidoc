extension DOM
{
    @frozen @usableFromInline
    struct Property<ID> where ID:Attribute
    {
        @usableFromInline internal
        let attribute:ID
        @usableFromInline internal
        let value:String

        @inlinable internal
        init(_ attribute:ID, _ value:String)
        {
            self.attribute = attribute
            self.value = value
        }
    }
}
extension DOM.Property
{
    @inlinable internal static
    func += (utf8:inout [UInt8], self:Self)
    {
        utf8.append(0x20) // ' '
        utf8 += self.attribute.name.utf8

        if  self.value.isEmpty
        {
            return
        }

        utf8.append(0x3D) // '='
        utf8.append(0x27) // '''

        for byte:UInt8 in self.value.utf8
        {
            if  byte == 0x27
            {
                utf8 += "&#39;".utf8
            }
            else
            {
                utf8.append(byte)
            }
        }

        utf8.append(0x27) // '''
    }
}

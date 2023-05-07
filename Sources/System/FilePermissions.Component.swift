extension FilePermissions
{
    @frozen public
    enum Component:UInt32
    {
        case x      = 0b001
        case w      = 0b010
        case wx     = 0b011
        case r      = 0b100
        case rx     = 0b101
        case rw     = 0b110
        case rwx    = 0b111
    }
}

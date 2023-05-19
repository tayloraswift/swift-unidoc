import Grammar

extension MultipartHeaderRule
{
    enum OpaqueFieldValue:TerminalRule
    {
        typealias Location = Int
        typealias Terminal = UInt8
        typealias Construction = Void

        static
        func parse(terminal:UInt8) -> Void?
        {
            switch terminal
            {
            case    0x09,           // '\t'
                    0x20 ... 0x7e,  // ' ', VCHAR
                    0x80 ... 0xff:
                return ()
            default:
                return nil
            }
        }
    }
}

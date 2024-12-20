extension UCF.Selector.PathComponent
{
    struct OperatorHead
    {
        private
        init()
        {
        }
    }
}
extension UCF.Selector.PathComponent.OperatorHead
{
    @inlinable public
    init?(_ codepoint:Unicode.Scalar)
    {
        switch codepoint
        {
        case    ".",
                "/", "=", "-", "+", "!", "*", "%", "<", ">", "&", "|", "^", "~", "?",
                "\u{00A1}" ... "\u{00A7}",
                "\u{00A9}", "\u{00AB}",
                "\u{00AC}", "\u{00AE}",
                "\u{00B0}" ... "\u{00B1}",
                "\u{00B6}",
                "\u{00BB}",
                "\u{00BF}",
                "\u{00D7}",
                "\u{00F7}",
                "\u{2016}" ... "\u{2017}",
                "\u{2020}" ... "\u{2027}",
                "\u{2030}" ... "\u{203E}",
                "\u{2041}" ... "\u{2053}",
                "\u{2055}" ... "\u{205E}",
                "\u{2190}" ... "\u{23FF}",
                "\u{2500}" ... "\u{2775}",
                "\u{2794}" ... "\u{2BFF}",
                "\u{2E00}" ... "\u{2E7F}",
                "\u{3001}" ... "\u{3003}",
                "\u{3008}" ... "\u{3020}",
                "\u{3030}":
            self.init()
        default:
            return nil
        }
    }
}

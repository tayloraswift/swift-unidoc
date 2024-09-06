extension Unidoc
{
    struct BuildButton
    {
        let text:String?
        let type:BuildButtonType

        init(text:String?, type:BuildButtonType)
        {
            self.text = text
            self.type = type
        }
    }
}

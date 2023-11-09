extension Barbie
{
    /// Do you think we’re
    /// getting in? ``It looks like me, right?``
    public
    struct ID:Equatable
    {
        public
        let x:Int
        public private(set)
        var y:Int

        public
        init()
        {
            self.x = 0
            self.y = 0
        }
    }
}

extension Compiler
{
    @frozen public
    struct Documentation
    {
        public
        let comment:Comment
        public
        let scope:[String]

        init(comment:Comment, scope:[String])
        {
            self.comment = comment
            self.scope = scope
        }
    }
}

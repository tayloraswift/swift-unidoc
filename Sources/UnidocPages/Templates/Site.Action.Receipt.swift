import HTML
import URI

extension Site.Action
{
    @frozen public
    struct Receipt
    {
        public
        var action:Site.Action
        public
        var text:String

        @inlinable public
        init(action:Site.Action, text:String)
        {
            self.action = action
            self.text = text
        }
    }
}
extension Site.Action.Receipt:FixedPage
{
    public
    var location:URI { Site.Action.uri.path / self.action.rawValue }

    public
    var title:String { "Action complete" }

    public
    func emit(main:inout HTML.ContentEncoder)
    {
        main[.p] = self.text
    }
}

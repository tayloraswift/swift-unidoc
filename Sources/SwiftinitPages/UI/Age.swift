import HTML

struct Age<Locale>
{
    public
    var seconds:Int64

    @inlinable public
    init(seconds:Int64)
    {
        self.seconds = seconds
    }
}
extension Age
{
    @inlinable public
    init(_ duration:Duration)
    {
        self.init(seconds: duration.components.seconds)
    }
}
extension Age<Language.EN>:CustomStringConvertible
{
    var description:String
    {
        if      self.seconds < 2 * 60
        {
            "just now"
        }
        else if self.seconds < 2 * 60 * 60
        {
            "\(self.seconds / 60) minutes ago"
        }
        else if self.seconds < 2 * 24 * 3600
        {
            "\(self.seconds / 3600) hours ago"
        }
        else
        {
            "\(self.seconds / 86400) days ago"
        }
    }
}

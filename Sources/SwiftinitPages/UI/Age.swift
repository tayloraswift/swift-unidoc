import HTML

struct Age
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
extension Age
{
    var short:String
    {
        if      self.seconds < 2 * 60
        {
            "\(self.seconds) s)"
        }
        else if self.seconds < 2 * 60 * 60
        {
            "\(self.seconds / 60) m"
        }
        else if self.seconds < 2 * 24 * 3600
        {
            "\(self.seconds / 3600) h"
        }
        else
        {
            "\(self.seconds / 86400) d"
        }
    }

    var long:String
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

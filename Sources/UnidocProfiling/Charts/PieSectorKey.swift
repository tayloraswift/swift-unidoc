import HTML

public
protocol PieSectorKey:Identifiable<String>
{
    associatedtype ShareFormat:PieShareFormat = PieShareFormat1F

    /// An identifier for the sector, which will be used as a CSS class name.
    override
    var id:String { get }
    /// A human-readable name for the sector.
    var name:String { get }
}
extension PieSectorKey
{
    /// Renders the legend key for this sector if the share is significant enough to display.
    /// The instance’s ``name`` is used for the display text.
    @inlinable public
    func legend(_ html:inout HTML.ContentEncoder, share:ShareFormat)
    {
        guard
        let share:String = share.formatted
        else
        {
            return
        }

        html[.dt] { $0.class = self.id } = "\(self.name)"
        html[.dd] = "\(share)%"
    }
}

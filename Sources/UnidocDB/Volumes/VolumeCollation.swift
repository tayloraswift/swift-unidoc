import MongoDB

@frozen public
struct VolumeCollation:DatabaseCollation
{
    @inlinable public static
    var spec:Mongo.Collation
    {
        .init(locale: "en", // casing is a property of english, not unicode
            caseLevel: false, // url paths are case-insensitive
            normalization: true, // normalize unicode on insert
            strength: .secondary) // diacritics are significant
    }
}

import MongoQL

extension Mongo.Collation {
    @inlinable public static var casefolding: Self {
        .init(
            locale: "en", // casing is a property of english, not unicode
            caseLevel: false, // url paths are case-insensitive
            normalization: true, // normalize unicode on insert
            strength: .secondary
        ) // diacritics are significant
    }

    @inlinable public static var simple: Self {
        .init(locale: "simple", normalization: true) // normalize unicode on insert
    }
}

import UniformTypeIdentifiers

extension UTType {
    /// The package on disk – your `.visuals` document
    static var visuals: UTType {
        UTType(exportedAs: "com.homeymusic.visuals")
    }

    /// One slide inside that package – used for Copy/Paste, Drag & Drop
    static var visualsSlide: UTType {
        UTType(exportedAs: "com.homeymusic.visuals.slide")
    }
}

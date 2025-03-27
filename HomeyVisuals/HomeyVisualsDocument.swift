import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    /// Custom UTI for Homey Visuals documents.
    static var visual: UTType {
        UTType(exportedAs: "com.homeymusic.visuals")
    }
}

struct HomeyVisualsDocument: FileDocument {
    var text: String
    
    // Default initializer.
    init(text: String = "Hello, world!") {
        self.text = text
    }
    
    // Specify that our document uses the custom UTI.
    static var readableContentTypes: [UTType] { [.visual] }
    
    // Read initializer: Look inside the "Data" directory for "document.txt".
    init(configuration: ReadConfiguration) throws {
        let wrapper = configuration.file
        if wrapper.isDirectory, let fileWrappers = wrapper.fileWrappers {
            // Look for the "Data" directory.
            if let dataWrapper = fileWrappers["Data"],
               dataWrapper.isDirectory,
               let dataFileWrappers = dataWrapper.fileWrappers,
               let documentWrapper = dataFileWrappers["document.txt"],
               let data = documentWrapper.regularFileContents,
               let string = String(data: data, encoding: .utf8) {
                self.text = string
                return
            }
        }
        // Fallback: If it's a simple file.
        if let data = wrapper.regularFileContents,
           let string = String(data: data, encoding: .utf8) {
            self.text = string
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    // Write method: Create a package structure with a "Data" folder containing "document.txt",
    // plus additional folders and preview images at the package root.
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        // 1. Create the main document file ("document.txt") with the text.
        let documentData = text.data(using: .utf8)!
        var documentFile = FileWrapper(regularFileWithContents: documentData)
        documentFile.preferredFilename = "document.txt"
        
        // 2. Create the Data directory and add "document.txt" to it.
        let dataDirectory = FileWrapper(directoryWithFileWrappers: ["document.txt": documentFile])
        dataDirectory.preferredFilename = "Data"
        
        // 3. Create empty directories for Index and Metadata.
        let indexDirectory = FileWrapper(directoryWithFileWrappers: [:])
        indexDirectory.preferredFilename = "Index"
        
        let metadataDirectory = FileWrapper(directoryWithFileWrappers: [:])
        metadataDirectory.preferredFilename = "Metadata"
        
        // 4. Create preview image files with placeholder empty data.
        let previewMicro = FileWrapper(regularFileWithContents: Data())
        previewMicro.preferredFilename = "preview-micro.jpg"
        
        let previewWeb = FileWrapper(regularFileWithContents: Data())
        previewWeb.preferredFilename = "preview-web.jpg"
        
        let preview = FileWrapper(regularFileWithContents: Data())
        preview.preferredFilename = "preview.jpg"
        
        // 5. Assemble all components into the root directory (the package).
        let rootWrapper = FileWrapper(directoryWithFileWrappers: [
            "Data": dataDirectory,
            "Index": indexDirectory,
            "Metadata": metadataDirectory,
            "preview-micro.jpg": previewMicro,
            "preview-web.jpg": previewWeb,
            "preview.jpg": preview
        ])
        
        return rootWrapper
    }
}

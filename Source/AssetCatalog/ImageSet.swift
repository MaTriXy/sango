//
// ImageSet.swift
// Iconizer
// https://github.com/raphaelhanneken/iconizer
//

import Cocoa

/// Creates and saves an Image Set asset catalog.
class ImageSet: NSObject {

    /// The resized images.
    var images: [String: NSImage] = [:]

    /// Create the @1x and @2x images from the supplied image.
    ///
    /// - Parameter image: The image to resize.
    func generateScaledImagesFromImage(_ image: NSImage) {
        // Define the new image sizes.
        let scaleX1 = NSSize(width: ceil(image.width / 3), height: ceil(image.height / 3))
        let scaleX2 = NSSize(width: ceil(image.width / 1.5), height: ceil(image.height / 1.5))

        // Calculate the 2x and 1x images.
        images["1x"] = image.resize(toSize: scaleX1, aspectMode: .fit)
        images["2x"] = image.resize(toSize: scaleX2, aspectMode: .fit)

        // Assign the original images as the 3x image.
        images["3x"] = image
    }

    /// Write the Image Set to the supplied file url.
    ///
    /// - Parameters:
    ///   - name: The name of the asset catalog.
    ///   - url: The URL to save the catalog to.
    /// - Throws: See ImageSetError for possible values.
    func saveAssetCatalogNamed(_ name: String, toURL url: URL) throws {
        let url = url.appendingPathComponent("\(imageSetDir)/\(name).imageset", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true,
                                                attributes: nil)

        // Manage the Contents.json with an empty platforms array since we don't care
        // about platforms for Image Sets.
        var jsonFile = try ContentsJSON(forType: IconAssetType.imageSet, andPlatforms: [""])
        for image in jsonFile.images {
            // Unwrap the information we need.
            guard let scale = image["scale"], let filename = image["filename"] else {
                throw ImageSetError.gettingJSONDataFailed
            }
            // Get the correct image.
            guard let img = self.images[scale] else {
                throw ImageSetError.missingImage
            }
            // Save the png representation to the supplied url.
            try img.savePngTo(url: url.appendingPathComponent(filename))
        }
        try jsonFile.saveToURL(url)
        images = [:]
    }
}

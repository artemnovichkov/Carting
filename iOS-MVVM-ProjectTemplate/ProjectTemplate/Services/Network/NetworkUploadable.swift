import UIKit
import Alamofire
import ACKategories

protocol NetworkUploadable {
    func append(multipart: MultipartFormData)
}

struct PrimitiveUploadable: NetworkUploadable {
    typealias Value = CustomStringConvertible

    let key: String
    let value: Value?

    func append(multipart: MultipartFormData) {
        guard let value = value, let dataValue = value.description.data(using: .utf8) else { return }
        multipart.append(dataValue, withName: key)
    }
}

struct ImageUploadable: NetworkUploadable {
    enum Defaults {
        static let maxDimension: CGFloat = 1_024
        static let compressionQuality: CGFloat = 0.95
    }

    let key: String
    let fileName: String
    let mimeType: String
    let image: UIImage

    var maxDimension = Defaults.maxDimension
    var compressionQuality = Defaults.compressionQuality

    func append(multipart: MultipartFormData) {
        let fixedOrientationImage = image.fixedOrientation()
        let resizedImage = fixedOrientationImage.resized(maxDimension: maxDimension) ?? image

        if let imageData = resizedImage.jpegData(compressionQuality: compressionQuality) {
            multipart.append(imageData, withName: key, fileName: fileName, mimeType: mimeType)
        }
    }
}

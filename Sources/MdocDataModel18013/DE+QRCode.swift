//
//  DE+QRCode.swift

import Foundation
import SwiftCBOR
#if canImport(CoreImage)
import CoreImage
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

public enum InputCorrectionLevel: Int {
    /// L 7%.
    case l = 0
    /// M 15%.
    case m = 1
    /// Q 25%.
    case q = 2
    /// H 30%.
    case h = 3
}

extension DeviceEngagement {
    var qrCode: String { "mdoc:" + Data(encode(options: .init())).base64URLEncodedString() }
}

#if os(iOS)
extension DeviceEngagement {
    /// Create QR CIImage
    public func getQrCodeImage(_ inputCorrectionLevel: InputCorrectionLevel = .m) -> UIImage? {
        guard let stringData = qrCode.data(using: .utf8) else { return nil}
        let correctionLevel = ["L", "M", "Q", "H"][inputCorrectionLevel.rawValue]
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrFilter.setDefaults()
        qrFilter.setValue(stringData, forKey: "inputMessage")
        qrFilter.setValue(correctionLevel, forKey: "inputCorrectionLevel")
        let transform = CGAffineTransform(scaleX: 6, y: 6)
        guard let ciImage = qrFilter.outputImage?.transformed(by: transform) else { return nil }
        // attempt to get a CGImage from our CIImage
        let context = CIContext()
        guard let cgimg = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        // convert that to a UIImage
        let uiImage = UIImage(cgImage: cgimg)
        return uiImage
    }
}
#endif

/*
Copyright (c) 2023 European Commission

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

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
    var qrCode: String { "mdoc:" + Data(qrCoded!).base64URLEncodedString() }

#if os(iOS)
    /// Create QR CIImage
    public mutating func getQrCodeImage(_ inputCorrectionLevel: InputCorrectionLevel = .m) -> UIImage? {
		qrCoded = encode(options: CBOROptions())
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
	
    /// Create QR string payload
    public mutating func getQrCodePayload() -> String {
	qrCoded = encode(options: CBOROptions())
	return qrCode
    }
#endif
}

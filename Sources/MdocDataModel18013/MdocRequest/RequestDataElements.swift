import Foundation
import SwiftCBOR

typealias IntentToRetain = Bool

struct RequestDataElements {
    let dataElements: [DataElementIdentifier: IntentToRetain]
   
}
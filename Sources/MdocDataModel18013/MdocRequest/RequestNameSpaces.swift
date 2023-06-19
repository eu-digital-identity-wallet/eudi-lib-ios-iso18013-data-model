import Foundation
import SwiftCBOR

struct RequestNameSpaces {
    let nameSpaces: [NameSpace: RequestDataElements]
    subscript(ns: String)-> RequestDataElements? { nameSpaces[ns] }
} 
 
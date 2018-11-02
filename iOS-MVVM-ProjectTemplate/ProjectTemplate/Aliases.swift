// Aliases for common used types

import enum Alamofire.HTTPMethod
import protocol Alamofire.ParameterEncoding
import struct Alamofire.HTTPHeaders
import struct Alamofire.URLEncoding
import struct Alamofire.JSONEncoding
import class Alamofire.MultipartFormData

import enum Result.NoError

typealias NoError = Result.NoError

typealias HTTPMethod = Alamofire.HTTPMethod
typealias ParameterEncoding = Alamofire.ParameterEncoding
typealias HTTPHeaders = Alamofire.HTTPHeaders
typealias URLEncoding = Alamofire.URLEncoding
typealias JSONEncoding = Alamofire.JSONEncoding
typealias MultipartFormData = Alamofire.MultipartFormData

typealias IdentifierType = Int64

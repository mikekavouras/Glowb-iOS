//
//  Photo.swift
//  Glowb
//
//  Created by Michael Kavouras on 12/12/16.
//  Copyright © 2016 Michael Kavouras. All rights reserved.
//

import Alamofire
import ObjectMapper
import PromiseKit

enum PhotoError: Error {
    case failedToCreate
    case invalidS3Params
    case failedToProcessImage
}

struct Photo: Mappable {
    var id: Int?
    var filename: String?
    var ext: String = ""
    var mimeType: String?
    var originalWidth: CGFloat = 0
    var originalHeight: CGFloat = 0
    var eTag: String = ""
    var token: String?
    var url: String?
    
    var s3Params: JSON?
    
    
    // MARK: - Life cycle
    // MARK: -
    
    init?(map: Map) {}
    
    
    // MARK: - Mapping
    // MARK: -
    
    mutating func mapping(map: Map) {
        id             <- map["id"]
        s3Params       <- map["params"]
        originalHeight <- map["original_height"]
        originalWidth  <- map["original_width"]
        url            <- map["url"]
        token          <- map["token"]
    }
    
    func toJSON() -> [String : Any] {
        return [
            "sha" : eTag,
            "original_width" : originalWidth,
            "original_height" : originalHeight,
        ]
    }
    
    
    // MARK: - API
    // MARK: -
    
    // MARK: create
    
    static func create(image: UIImage, uploadProgressHandler: @escaping (Progress) -> Void) -> Promise<Photo> {
        return Promise { fulfill, reject in
            
            guard let jpeg = UIImageJPEGRepresentation(image, 0.9) else {
                reject(PhotoError.failedToProcessImage)
                return
            }
            
            Alamofire.request(Router.createPhoto).validate().responseJSON { response in
                let result = PhotoParser.parseResponse(response)
                
                switch result {
                case .success(var photo):
                    
                    guard let params = photo.s3Params else {
                        reject(PhotoError.invalidS3Params)
                        return
                    }
                    
                    S3ImageUploader.uploadImage(jpeg: jpeg, params: params, progressHandler: uploadProgressHandler).then { eTag -> Void in
                        
                        photo.originalHeight = image.size.height
                        photo.originalWidth = image.size.width
                        photo.eTag = eTag
                        
                        photo.update().then { photo in
                            fulfill(photo)
                        }.catch { error in
                            reject(error)
                        }
                        
                    }.catch { error in
                        reject(error)
                    }
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }
    
    // MARK: update
    
    func update() -> Promise<Photo> {
        return Promise { fulfill, reject in
            Alamofire.request(Router.updatePhoto(self)).validate().responseJSON { response in
                let result = PhotoParser.parseResponse(response)
                
                switch result {
                case .success(let photo):
                    fulfill(photo)
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }
}

private struct PhotoParser: ServerResponseParser {
    static func parseJSON(_ json: JSON) -> Alamofire.Result<Photo> {
        guard let photo = Mapper<Photo>().map(JSON: json) else {
            return .failure(ServerError.invalidJSONFormat)
        }
        
        return .success(photo)
    }
}

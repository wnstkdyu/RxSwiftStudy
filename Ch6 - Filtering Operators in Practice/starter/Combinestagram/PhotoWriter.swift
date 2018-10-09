/*
 * Copyright (c) 2016-present Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import UIKit
import Photos
import RxSwift

class PhotoWriter {
    enum Errors: Error {
        case couldNotSavePhoto
    }
    
    //애플의 비동기 API를 래핑한 옵저버블
    static func save(_ image: UIImage) -> Single<String> {
        return Single.create(subscribe: { event in
            //이벤트를 만들자. 이미지를 저장하고, 저장끝났으면 아이디 반환하는 이벤트
            var savedAssetId: String?
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCreationRequest.creationRequestForAsset(from: image)
                savedAssetId = request.placeholderForCreatedAsset?.localIdentifier
            }, completionHandler: { success, error in
                DispatchQueue.main.async {
                    if success, let id = savedAssetId {
                        event(.success(id))
                    } else {
                        event(.error(error ?? Errors.couldNotSavePhoto))
                    }
                }
            })
            
            return Disposables.create()
        })
    }
}
                    
                    
//        return Observable.create({ observer in
//            var savedAssetID: String?
//            PHPhotoLibrary.shared().performChanges({
//                //받은 이미지로 photo asset을 만듦
//                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
//                savedAssetID = request.placeholderForCreatedAsset?.localIdentifier
//                }, completionHandler: { success, error in
//                    DispatchQueue.main.async {
//                        if success, let id = savedAssetID {
//                            observer.onNext(id)
//                            observer.onCompleted()
//                        } else {
//                            observer.onError(error ?? Errors.couldNotSavePhoto)
//                        }
//                    }
//            })
//            return Disposables.create()
//        })
        
//    }

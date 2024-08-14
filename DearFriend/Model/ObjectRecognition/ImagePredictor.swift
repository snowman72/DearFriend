//
//  ImagePredictor.swift
//  RealTimeObjectDetection
//
//  Created by Vũ Minh Hà on 13/8/24.
//

import Vision
import UIKit

class ImagePredictor {
    private static let imageClassifier = createImageClassifier()
    
    struct Prediction {
        let classification: String
        let confidencePercentage: String
    }
    
    typealias ImagePredictionHandler = (_ predictions: [Prediction]?) -> Void
    
    private static func createImageClassifier() -> VNCoreMLModel {
        let defaultConfig = MLModelConfiguration()
        
        guard let imageClassifier = try? MobileNet(configuration: defaultConfig).model,
              let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifier) else {
            fatalError("Failed to create image classifier")
        }
        
        return imageClassifierVisionModel
    }
    
    func makePredictions(for photo: UIImage, completionHandler: @escaping ImagePredictionHandler) throws {
        let orientation = photo.imageOrientation.toCGImagePropertyOrientation()
        
        guard let photoImage = photo.cgImage else {
            throw NSError(domain: "ImagePredictor", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get CGImage from UIImage"])
        }
        
        let handler = VNImageRequestHandler(cgImage: photoImage, orientation: orientation)
        let request = createImageClassificationRequest(completionHandler: completionHandler)
        
        try handler.perform([request])
    }
    
    private func createImageClassificationRequest(completionHandler: @escaping ImagePredictionHandler) -> VNRequest {
        let imageClassificationRequest = VNCoreMLRequest(model: ImagePredictor.imageClassifier) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                completionHandler(nil)
                return
            }
            
            let predictions = results.map { observation in
                Prediction(classification: observation.identifier,
                           confidencePercentage: String(format: "%.2f", observation.confidence * 100))
            }
            
            completionHandler(predictions)
        }
        
        imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        return imageClassificationRequest
    }
}

extension UIImage.Orientation {
    func toCGImagePropertyOrientation() -> CGImagePropertyOrientation {
        switch self {
        case .up: return .up
        case .upMirrored: return .upMirrored
        case .down: return .down
        case .downMirrored: return .downMirrored
        case .left: return .left
        case .leftMirrored: return .leftMirrored
        case .right: return .right
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}

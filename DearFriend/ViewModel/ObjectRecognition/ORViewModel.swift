//
//  ORViewModel.swift
//  DearFriend
//
//  Created by Vũ Minh Hà on 9/8/24.
//

import Foundation
import Combine
import Vision
import VisionKit

class ORViewModel: ObservableObject {
    
    @Published private(set) var predictionLabel = ""
    
    @Published private var capturedImage: UIImage? = nil
    
    
    func classifyImage(uiImage: UIImage) {
        guard let ciImage = CIImage(image: uiImage) else { return }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        let request = VNClassifyImageRequest { request, error in
            if let result = request.results as? [VNClassificationObservation] {
                print("\(result.first?.identifier ?? String())")
            }
        }
        
        
        do {
            try handler.perform([request])
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    func ObjectRecognizerClassifyImage(uiImage: UIImage) {
        let resizeImage = uiImage.resizeImageTo(size: CGSize(width: 224, height: 224))
        
        guard let cvPixelBuffer = resizeImage?.convertToBuffer() else { return }
        
        do {
            let model = try ObjectRecognizer(configuration: MLModelConfiguration())
            let prediction = try model.prediction(image: cvPixelBuffer)
            print("Object Recognizer: \(prediction.classLabel)")
            predictionLabel = prediction.classLabel
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

//
//  CameraViewModel.swift
//  RealTimeObjectDetection
//
//  Created by Vũ Minh Hà on 13/8/24.
//

import AVFoundation
import Vision
import UIKit
import SwiftUI

class CameraViewModel: NSObject, ObservableObject {
    @Published var identifiedObject: String = "Scanning..."
    @Published var errorMessage: String?
    
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let captureOutput = AVCaptureVideoDataOutput()
    private var imagePredictor = ImagePredictor()
    private let synthesizer = AVSpeechSynthesizer()
    private var lastSpokenObject: String?
    
    private var lastPredictionTime: Date = Date()
    private let predictionInterval: TimeInterval = 1.0 // 1 second interval
    
    
    override init() {
        super.init()
        checkCameraAuthorization()
    }
    
    func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupCaptureSession()
                } else {
                    self.errorMessage = "Camera access is required for this app to function."
                }
            }
        case .denied, .restricted:
            self.errorMessage = "Camera access is required. Please enable it in Settings."
        @unknown default:
            self.errorMessage = "Unknown camera authorization status."
        }
    }
    
    private func setupCaptureSession() {
        sessionQueue.async {
            self.session.beginConfiguration()
            
            // Add video input
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                self.errorMessage = "Unable to access the back camera."
                return
            }
                    
            do {
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                guard self.session.canAddInput(videoDeviceInput) else {
                    self.errorMessage = "Unable to add video device input to the session."
                    return
                }
                self.session.addInput(videoDeviceInput)
            } catch {
                self.errorMessage = "Unable to create video device input: \(error.localizedDescription)"
                return
            }
            
            
            
            // Add video output
            self.captureOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
            guard self.session.canAddOutput(self.captureOutput) else {
                self.errorMessage = "Unable to add video output to the session."
                return
            }
            self.session.addOutput(self.captureOutput)
            
            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }
    
    private func speakIdentifiedObject(_ object: String) {
        // Only speak if the object is different from the last spoken object
        guard object != lastSpokenObject else { return }
        
        DispatchQueue.main.async {
            let utterance = AVSpeechUtterance(string: object)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.5
            
            self.synthesizer.speak(utterance)
            self.lastSpokenObject = object
        }
    }
    
    private func shouldMakePrediction() -> Bool {
        let currentTime = Date()
        if currentTime.timeIntervalSince(lastPredictionTime) >= predictionInterval {
            lastPredictionTime = currentTime
            return true
        }
        return false
    }
}

extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard shouldMakePrediction() else { return }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            self.errorMessage = "Unable to get image from sample buffer."
            return
        }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            self.errorMessage = "Unable to create CGImage from CIImage."
            return
        }
        
        let image = UIImage(cgImage: cgImage)
        
        do {
            try self.imagePredictor.makePredictions(for: image) { predictions in
                DispatchQueue.main.async {
                    if let topPrediction = predictions?.first {
                        let identifiedObject = topPrediction.classification
                        self.identifiedObject = "\(topPrediction.classification) - \(topPrediction.confidencePercentage)%"
                        self.speakIdentifiedObject(identifiedObject)
                        
                    } else {
                        self.identifiedObject = "No object detected"
                    }
                }
            }
        } catch {
            self.errorMessage = "Failed to make predictions: \(error.localizedDescription)"
        }
    }
}

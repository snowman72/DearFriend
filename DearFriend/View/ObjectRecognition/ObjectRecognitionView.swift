//
//  ObjectRecognitionView.swift
//  DearFriend
//
//  Created by Vũ Minh Hà on 9/8/24.
//

import SwiftUI

struct ObjectRecognitionView: View {
    
    let cameraService = CameraService()
    @Binding var capturedImage: UIImage?
    
    @Environment(\.presentationMode) private var presentationMode
    
    
    var body: some View {
        
        ZStack {
            CameraView(cameraService: cameraService) { result in
                switch result {
                    
                case .success(let photo):
                    if let data = photo.fileDataRepresentation() {
                        capturedImage = UIImage(data: data)
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        print("Error: no image data found")
                    }
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
            
            VStack {
                Spacer()
                Button(action: {
                    cameraService.capturePhoto()
                }, label: {
                    Image(systemName: "circle")
                        .font(.system(size: 72))
                        .foregroundColor(.white)
                })
                .padding(.bottom)
            }
        }
    }
}



//
//  ObjectRecognitionView.swift
//  DearFriend
//
//  Created by Vũ Minh Hà on 9/8/24.
//

import SwiftUI

struct ObjectRecognitionView: View {
    
    @StateObject private var viewModel = CameraViewModel()
    
    var body: some View {
        ZStack {
            if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
            } else {
                
                // Camera preview
                CameraPreview(session: viewModel.session)
                    .edgesIgnoringSafeArea(.all)
                
                // Object identification overlay
                VStack {
                    Spacer()
                    Text(viewModel.identifiedObject)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom)
                }
            }
        }
    }
}



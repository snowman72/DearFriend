//
//  ContentView.swift
//  DearFriend
//
//  Created by Vũ Minh Hà on 3/8/24.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var capturedImage: UIImage? = nil
    @State private var isCustomCameraViewPresented = false
    @StateObject private var orViewModel = ORViewModel()
    
    var body: some View {
        ZStack {
            if capturedImage != nil {
                ZStack {
                    Image(uiImage: capturedImage!)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    Rectangle()
                        .frame(height: 70)
                        .foregroundColor(.blue)
                        .overlay(
                            Text(orViewModel.predictionLabel)
                                .foregroundStyle(Color.white)
                        )
                }
                .onAppear {
                    orViewModel.classifyImage(uiImage: capturedImage!)
                    
                    orViewModel.ObjectRecognizerClassifyImage(uiImage: capturedImage!)
                }
            } else {
                Color(UIColor.systemBackground)
            }
            
            VStack {
                Spacer()
                Button(action: {
                    isCustomCameraViewPresented.toggle()
                }, label: {
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                })
                .padding()
                .sheet(isPresented: $isCustomCameraViewPresented, content: {
                    ObjectRecognitionView(capturedImage: $capturedImage)
                })
            }
        }
    }
}

#Preview {
    ContentView()
}

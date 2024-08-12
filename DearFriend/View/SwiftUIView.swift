//
//  SwiftUIView.swift
//  DearFriend
//
//  Created by Vũ Minh Hà on 3/8/24.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .padding(.bottom, 20)
                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            Text("InputViews in View do not need to think:) , it should just show what you tell it to")
                .padding(.bottom)
            Text("InputViews in ViewModel would do all business logic")
        }
        .padding()
    }
}

#Preview {
    SwiftUIView()
}

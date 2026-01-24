//
//  ContentView.swift
//  FFCI
//
//  Firefighters for Christ International
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "flame.fill")
                .font(.system(size: 80))
                .foregroundColor(Color("PrimaryColor"))
            
            Text("FFCI")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Firefighters for Christ")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Spacer().frame(height: 40)
            
            Text("Hello World!")
                .font(.headline)
                .foregroundColor(Color("SecondaryColor"))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

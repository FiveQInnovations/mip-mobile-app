//
//  ContentView.swift
//  FFCI
//
//  Firefighters for Christ International
//

import SwiftUI
import os.log

// Logger for the app
private let logger = Logger(subsystem: "com.fiveq.ffci", category: "UI")

struct ContentView: View {
    @State private var showingDetail = false
    
    var body: some View {
        NavigationStack {
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
                
                Button(action: {
                    logger.info("🔥 Hello World button tapped!")
                    print("📱 [FFCI] Hello World button was tapped - navigating to detail screen")
                    showingDetail = true
                }) {
                    Text("Hello World!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color("SecondaryColor"))
                        .cornerRadius(8)
                }
                .navigationDestination(isPresented: $showingDetail) {
                    DetailView()
                }
            }
            .padding()
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("You Made It!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("This is the detail screen.")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Text("Navigation is working!")
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer().frame(height: 40)
            
            Button(action: {
                logger.info("🔙 Back button tapped on detail screen")
                print("📱 [FFCI] Back button tapped - dismissing detail screen")
                dismiss()
            }) {
                Text("Go Back")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color("PrimaryColor"))
                    .cornerRadius(8)
            }
        }
        .padding()
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            logger.info("📄 Detail screen appeared")
            print("📱 [FFCI] Detail screen is now visible")
        }
    }
}

#Preview {
    ContentView()
}

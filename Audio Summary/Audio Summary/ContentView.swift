//
//  ContentView.swift
//  Audio Summary
//
//  Created by 柳培铎 on 3/18/24.
//

import SwiftUI
import UIKit



struct ContentView: View {
    @EnvironmentObject var globalData: GlobalData

    var body: some View {
        NavigationView {
            ZStack {
                // Background image
                Image("background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all) // Ensure it goes under the navigation bar
//                    .scaledToFit()

                // Content
                VStack(spacing: 30) { // Increase spacing between buttons for clarity
                    NavigationLink(destination: RecordAudioView().environmentObject(globalData)) {
                        VStack {
                            Image(systemName: "mic.fill") // Icon
                                .resizable() // Allow resizing
                                .scaledToFit() // Maintain aspect ratio
                                .frame(width: 80, height: 80) // Specify icon size
                                .foregroundColor(.white)
                            Text("Record")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .font(.title) // Larger font size for text
                        }
                        .frame(width: 200, height: 200) // Larger frame for a bigger circle
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom)) // Gradient background
                        .clipShape(Circle()) // Ensure circular shape
                        .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 10) // Add shadow for depth
                    }
                    .buttonStyle(PlainButtonStyle()) // Apply custom styling

                    NavigationLink(destination: AllRecordingsView().environmentObject(globalData)) {
                        VStack {
                            Image(systemName: "list.bullet") // Icon
                                .resizable() // Allow resizing
                                .scaledToFit() // Maintain aspect ratio
                                .frame(width: 80, height: 80) // Specify icon size
                                .foregroundColor(.white)
                            Text("Your \nRecordings")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .font(.title) // Larger font size for text
                                .multilineTextAlignment(.center) // Center-align for multi-line
                        }
                        .frame(width: 220, height: 220) // Larger frame for a bigger circle
                        .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .top, endPoint: .bottom)) // Gradient background
                        .clipShape(Circle()) // Ensure circular shape
                        .shadow(color: .green.opacity(0.5), radius: 10, x: 0, y: 10) // Add shadow for depth
                    }
                    .buttonStyle(PlainButtonStyle()) // Apply custom styling
                }
                .padding() // Padding around the VStack for spacing from screen edges
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure VStack fills the screen
                .background(Color.black.opacity(0.3)) // Semi-transparent background for contrast
                .navigationBarTitle("Main Menu", displayMode: .large)

            }
        }
    }
}

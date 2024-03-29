//
//  Audio_SummaryApp.swift
//  Audio Summary
//
//  Created by 柳培铎 on 3/18/24.
//

import SwiftUI

import SwiftUI
import FirebaseCore
import GoogleSignIn

struct AudioRecording: Identifiable {
    let id = UUID()
    var title: String
    var fileURL: URL
    var summary: String
}

class GlobalData: ObservableObject {
    @Published var recordings: [AudioRecording] = [
    ]
    
    func addRecording(_ recording: AudioRecording) {
        DispatchQueue.main.async {
            self.recordings.append(recording)
        }
    }
}

@main
struct Audio_SummaryApp: App {
    var globalData = GlobalData()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(globalData)
        }
    }
}

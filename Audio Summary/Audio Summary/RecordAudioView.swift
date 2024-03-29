import SwiftUI
import AVFoundation

class AudioRecorderViewModel: ObservableObject 
{
    var audioRecorder: AVAudioRecorder?
    @Published var isRecording = false
    weak var globalData: GlobalData?

    
    func startRecording() {
        print("started ")
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session")
            return
        }
        self.isRecording = true
        
        print("self.isRecording:", self.isRecording)
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "Recording_\(Date().timeIntervalSince1970).m4a"
        let audioFilename = documentPath.appendingPathComponent(fileName)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderBitRateKey : 320000,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
        } catch {
            print("Could not start recording")
        }
        print("41")
    }
    
    func stopRecording(title: String) {
        print("51")
        audioRecorder?.stop()
        isRecording = false
        guard let url = audioRecorder?.url else { return }
        let newRecording = AudioRecording(title: title, fileURL: url, summary: "dum")
        print("not new recording")
        DispatchQueue.main.async {
            self.globalData?.addRecording(newRecording)
            print("Added new recording")
        }
    }
}



struct RecordAudioView: View 
{
    @EnvironmentObject var globalData: GlobalData

    @StateObject private var audioRecorderViewModel = AudioRecorderViewModel()
    
    @State private var recordingName: String = ""
    
        var body: some View
        {
            VStack(spacing: 30) { // Increase spacing between elements

                // Naming TextField and Submit Button
                Text("Name this recording before proceeding")
                    .font(.headline) // Make the prompt more noticeable
                    .padding(.bottom, 5)

                TextField("Enter name", text: $recordingName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Submit") {
                    print("Recording name: \(recordingName)")
                }
                .disabled(recordingName.isEmpty)
                .padding()
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 5) // Add shadow

                // Start Recording Button
                Button(action: {
                    audioRecorderViewModel.startRecording()
                }) {
                    Image(systemName: "mic.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .foregroundColor(.white)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)) // Use gradient
                        .clipShape(Circle())
                        .shadow(radius: 10) // Add shadow
                }
                .disabled(audioRecorderViewModel.isRecording || recordingName.isEmpty)
                .scaleEffect(audioRecorderViewModel.isRecording ? 1.1 : 1.0) // Add subtle animation effect
                .animation(.easeInOut, value: audioRecorderViewModel.isRecording)

                // Stop Recording Button
                Button(action: {
                    audioRecorderViewModel.stopRecording(title: recordingName)
                }) {
                    Image(systemName: "stop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .foregroundColor(.white)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing)) // Use gradient
                        .clipShape(Circle())
                        .shadow(radius: 10) // Add shadow
                }
                .disabled(!audioRecorderViewModel.isRecording)
                .scaleEffect(!audioRecorderViewModel.isRecording ? 1.1 : 1.0) // Add subtle animation effect
                .animation(.easeInOut, value: audioRecorderViewModel.isRecording)
            }
            .padding() // Add padding around the entire VStack
            .onAppear
            {
                requestMicrophonePermission()
                audioRecorderViewModel.globalData = globalData
            }
        }
        
        func requestMicrophonePermission()
        {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    print("Microphone permission granted")
                } else {
                    print("Microphone permission denied")
                }
            }
        }
}

#Preview {
    RecordAudioView()
}

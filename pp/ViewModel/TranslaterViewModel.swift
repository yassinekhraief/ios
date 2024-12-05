//
//  TranslatorViewModel.swift
//  pp
//
//  Created by Apple Esprit on 28/11/2024.
//

import Foundation
import Speech
import AVFoundation
import GoogleGenerativeAI

class translaterViewModel: ObservableObject {
    @Published var translatedText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isRecording: Bool = false  // Track if recording is in progress

    private let model: GenerativeModel
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine: AVAudioEngine?

    private let speechSynthesizer = AVSpeechSynthesizer()

    init() {
        self.model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        self.audioEngine = AVAudioEngine()
    }
    
    func requestSpeechPermissions() {
        // Request authorization for speech recognition
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self.errorMessage = nil
                case .denied:
                    self.errorMessage = "Speech recognition authorization denied."
                case .restricted:
                    self.errorMessage = "Speech recognition is restricted."
                case .notDetermined:
                    self.errorMessage = "Speech recognition authorization not determined."
                @unknown default:
                    self.errorMessage = "Unknown error occurred while requesting speech recognition permissions."
                }
            }
        }
    }

    func startRecording() {
        // Check if the speech recognizer is available and permission is granted
        requestSpeechPermissions()

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            self.errorMessage = "Speech recognizer is not available."
            return
        }
        
        do {
            // Configure the audio engine and recognition request
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            recognitionRequest?.shouldReportPartialResults = true

            recognitionTask = recognizer.recognitionTask(with: recognitionRequest!) { result, error in
                if let result = result {
                    self.translatedText = result.bestTranscription.formattedString
                }
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.stopRecording()
                }
            }

            let inputNode = audioEngine!.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)

            // Install a tap to capture the microphone input
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }

            audioEngine?.prepare()
            try audioEngine?.start()

            isRecording = true
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func stopRecording() {
        // Stop the audio engine and end the recognition request
        audioEngine?.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.finish()

        isRecording = false
    }

    func translateText(from sourceLanguage: String, to targetLanguage: String, text: String) {
        // Reset the state before starting a new request
        translatedText = ""
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Build the conversation context or the translation request
                let prompt = "Translate this text from \(sourceLanguage) to \(targetLanguage): \(text)"
                
                // Generate the translation using Gemini API
                let response = try await model.generateContent(prompt)
                
                // Handle the response and extract the translated text
                guard let translated = response.text else {
                    throw NSError(domain: "TranslatorViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No translation received."])
                }
                
                // Update the translated text on the main thread
                DispatchQueue.main.async {
                    self.translatedText = translated
                }
            } catch {
                // Handle error during translation
                DispatchQueue.main.async {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                }
            }
            
            // Hide the loading indicator
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }

    func speakTranslation() {
        let utterance = AVSpeechUtterance(string: translatedText)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }
}



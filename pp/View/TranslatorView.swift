//
//  TranslatorView.swift
//  pp
//
//  Created by Apple Esprit on 28/11/2024.
//

import SwiftUI

struct TranslatorView: View {
    @StateObject private var viewModel = translaterViewModel()
    
    @State private var textToTranslate: String = ""
    @State private var sourceLanguage: String = "English"
    @State private var targetLanguage: String = "Spanish"
    
    let languages = ["English", "Spanish", "French", "German", "Chinese", "Japanese", "Arabic"]
    
    var body: some View {
        ZStack {
            Color.mint
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header Section with app title and description
                VStack {
                    Text("Instant Travel Translator")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Translate on-the-go during your travels")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(0.8)
                        .padding(.top, 5)
                }
                .padding(.top, 50)
                
                // Input Field for Text
                VStack(alignment: .leading, spacing: 10) {
                    Text("Enter text to translate:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("Type your text here", text: $textToTranslate)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(15)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .foregroundColor(.black)
                        .shadow(radius: 8)
                }
                .padding(.horizontal, 30)
                
                // Language Picker Section
                HStack(spacing: 30) {
                    VStack(alignment: .leading) {
                        Text("From")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Picker("Source Language", selection: $sourceLanguage) {
                            ForEach(languages, id: \.self) { language in
                                Text(language)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(height: 45)
                        .padding(10)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("To")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Picker("Target Language", selection: $targetLanguage) {
                            ForEach(languages, id: \.self) { language in
                                Text(language)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(height: 45)
                        .padding(10)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                }
                .padding(.horizontal, 30)
                
                // Translate Button
                Button(action: {
                    viewModel.translateText(from: sourceLanguage, to: targetLanguage, text: textToTranslate)
                }) {
                    Text("Translate")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("accentColor"))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                }
                .padding(.top, 20)
                .padding(.horizontal, 30)
                
                // Loading Indicator
                if viewModel.isLoading {
                    ProgressView("Translating...")
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("accentColor")))
                        .padding()
                }
                
                // Display Translated Text in a Floating Card
                if !viewModel.translatedText.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Translated Text")
                            .font(.headline)
                            .foregroundColor(Color("accentColor"))
                            .padding(.bottom, 8)
                        
                        Text(viewModel.translatedText)
                            .font(.body)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(radius: 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                    .transition(.move(edge: .bottom))
                    
                    // Listen to translation button
                    Button(action: {
                        viewModel.speakTranslation()
                    }) {
                        Text("Listen to Translation")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("accentColor"))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(radius: 10)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 30)
                }
                
                // Speech recognition button
                if !viewModel.isRecording {
                    Button(action: {
                        viewModel.startRecording()
                    }) {
                        Text("Start Recording")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("accentColor"))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(radius: 10)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 30)
                } else {
                    Button(action: {
                        viewModel.stopRecording()
                    }) {
                        Text("Stop Recording")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("accentColor"))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(radius: 10)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 30)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Translator")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TranslatorView_Previews: PreviewProvider {
    static var previews: some View {
        TranslatorView()
            .previewDevice("iPhone 14 Pro")
    }
}





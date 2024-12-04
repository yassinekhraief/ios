//
//  TranslatorView.swift
//  pp
//
//  Created by Apple Esprit on 28/11/2024.
//

import SwiftUI

struct TranslatorView: View {
    @State private var textToTranslate: String = ""  // Text input field
    @State private var translatedText: String = "Translation will appear here"  // Placeholder translation text

    var body: some View {
        VStack {
            // Title
            Text("Translator")
                .font(.largeTitle)
                .padding()

            // Text input field
            TextField("Enter text to translate", text: $textToTranslate)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Translate button (No action here, just for UI purposes)
            Button(action: {
                // No action for now
            }) {
                Text("Translate")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            // Display translated text (placeholder)
            Text(translatedText)
                .font(.title2)
                .foregroundColor(.gray)
                .padding()

            Spacer()
        }
        .padding()
    }
}

struct TranslatorView_Previews: PreviewProvider {
    static var previews: some View {
        TranslatorView()
    }
}


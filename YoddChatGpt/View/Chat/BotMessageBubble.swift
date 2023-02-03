/*
The MIT License (MIT)

 Copyright (c) 2023 Alessio Iodice

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


//
//  BotMessageBubble.swift
//  YoddChatGpt
//
//  Created by Ale on 29/01/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct BotMessageBubble: View {
    // MARK: - Environmental objects
    @Environment (\.managedObjectContext) var managedObjectContext
    
    // MARK: - ViewModels
    @StateObject var speechSynthesizer = SpeechSynthesizer.shared
    @ObservedObject var chatColors = ThemeViewModel.shared
    
    // MARK: - Properties
    var messageState : Bool
    var primaryColor : Color
    var secondaryColor : Color
    var message : Message
    var type : MessageType
    @State var scale = 0.8
    
    var body: some View {
        Menu {
            Button(action: {
                UIPasteboard.general.setValue(message.body!,
                forPasteboardType: UTType.plainText.identifier)
            }) {
                Label("Copy", systemImage: "doc.on.doc")
            }
            Button(action: {
                SpeechSynthesizer.shared.readString(text: message.body!)
            }) {
                Label("Listen", systemImage: "ear")
            }
            if message.saved {
                Button(action: {
                    DataController.shared.saveMessage(message: message, context: managedObjectContext)
                }) {
                    Label("Unsave", systemImage: "bookmark.fill")
                }
            } else {
                
                Button(action: {
                    DataController.shared.saveMessage(message: message, context: managedObjectContext)
                }) {
                    Label("Save", systemImage: "bookmark")
                }
            }
            
            Button(role: .destructive, action: {
                    DataController.shared.deleteData(context: managedObjectContext, message: message)
            
            }) {
                HStack {
                    Text("Delete")
                    Spacer()
                    Image(systemName: "trash")
                }
            }
        } label: {
            HStack {
                HStack {
                    if type == .text {
                        Text(message.body!)
                            .multilineTextAlignment(.leading)
                            .padding(.trailing, 30)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                            .padding(.leading, 5)
                    }
                    else if type == .error{
                        Text(message.body!)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.leading)
                            .padding(.trailing, 30)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                            .padding(.leading, 5)
                        
                    }
                }
                .background {
                    ZStack {
                        HStack {
                            Spacer()
                            if message.saved == true {
                                Image(systemName: "bookmark.fill")
                                    .padding(.trailing, 2)
                            }
                        }
                        
                        Rectangle().foregroundColor(secondaryColor)
                            .cornerRadius(20, corners: [.topRight, .bottomRight, .topLeft])
                            .padding(.trailing, 30).padding(.leading, 5)
                    }
                }
                .scaleEffect(scale)
                .onAppear{
                    let baseAnimation = Animation.easeIn(duration: 0.2)

                    withAnimation(baseAnimation) {
                        scale = 1
                    }
                }
            }
        }    .buttonStyle(.plain)
            .onChange(of: SpeechSynthesizer.shared.speechSynthesizer.isSpeaking) { state in
                print(state)
            }
    }
}


struct BotMessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        BotMessageBubble(messageState: true, primaryColor: .blue, secondaryColor: .teal, message: Message(), type: .text)
    }
}

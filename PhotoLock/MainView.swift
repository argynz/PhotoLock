//
//  MainView.swift
//  PhotoLock
//
//  Created by Argyn on 17.09.2024.
//

import SwiftUI
import PhotosUI
import PencilKit


@MainActor
final class MainViewModel: ObservableObject {
    @Published var selectedImage: UIImage? = nil
    @Published var croppingOptions = CroppedPhotosPickerOptions(doneButtonTitle: "Select", doneButtonColor: .orange)
    
    @Published var canvas = PKCanvasView()
    @Published var toolPicker = PKToolPicker()
    @Published var textBoxes: [TextBox] = []
    @Published var addNewBox = false
    @Published var currentIndex: Int = 0
    @Published var rect: CGRect = .zero
    @Published var showAlert = false
    @Published var message = ""
    
    func cancelImageEditing() {
        selectedImage = nil
        canvas = PKCanvasView()
        textBoxes.removeAll()
    }
    
    func cancelTextView() {
        toolPicker.setVisible(true, forFirstResponder: canvas)
        canvas.becomeFirstResponder()
        
        withAnimation {
            addNewBox = false
        }
        if !textBoxes[currentIndex].isAdded {
            textBoxes.removeLast()
        }
    }
    
    func saveImage() {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        canvas.drawHierarchy(in: CGRect(origin: .zero, size: rect.size), afterScreenUpdates: true)
        let SwiftUIView = ZStack {
            ForEach(textBoxes) { [self] box in
                Text(textBoxes[currentIndex].id == box.id && addNewBox ? "" : box.text)
                    .font(.system(size: 30))
                    .fontWeight(box.isBold ? . bold : .none)
                    .foregroundColor(box.textColor)
                    .offset(box.offset)
            }
        }
        let controller = UIHostingController(rootView: SwiftUIView).view!
        controller.frame = rect
        
        controller.backgroundColor = .clear
        canvas.backgroundColor = .clear
        
        controller.drawHierarchy(in: CGRect(origin: .zero, size: rect.size), afterScreenUpdates: true)
        
        let generatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = generatedImage?.pngData() {
            UIImageWriteToSavedPhotosAlbum(UIImage(data: image)!, nil, nil, nil)
            self.message = "Saved successully"
            self.showAlert.toggle()
        }
    }
    
    func signOut() throws {
        try AuthManager.shared.signOut()
    }
}

struct MainView: View {
    
    @StateObject private var viewModel = MainViewModel()
    @Binding var showSignInview: Bool
    
    var body: some View {
        ZStack {
            VStack {
                if viewModel.selectedImage != nil {
                    DrawingScreen()
                        .environmentObject(viewModel)
                        .toolbar(content: {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    viewModel.cancelImageEditing()
                                } label: {
                                    Image(systemName: "xmark")
                                }
                                .disabled(viewModel.addNewBox)
                            }
                            
                        })
                } else {
                    CroppedPhotosPicker(style: .default, options: viewModel.croppingOptions, selection: $viewModel.selectedImage) { rect in
                        print("Did crop to rect: \(rect)")
                    } didCancel: {
                        print("Did cancel")
                    } label: {
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundColor(.black)
                            .frame(width: 70, height: 70)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.07), radius: 5, x: 5, y: 5)
                            .shadow(color: Color.black.opacity(0.07), radius: 5, x: -5, y: -5)
                    }
                }
            }
            .navigationTitle("Photo Lock")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.selectedImage == nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Log out") {
                            Task {
                                do {
                                    try viewModel.signOut()
                                    showSignInview = true
                                } catch {
                                    print(error)
                                }
                            }
                        }
                    }
                }
            }
            
            if viewModel.addNewBox {
                Color.black.opacity(0.75)
                    .ignoresSafeArea()
                
                TextField("Type Here", text: $viewModel.textBoxes[viewModel.currentIndex].text)
                    .font(.system(size: 35, weight: viewModel.textBoxes[viewModel.currentIndex].isBold ? .bold : .regular))
                    .colorScheme(.dark)
                    .foregroundColor(viewModel.textBoxes[viewModel.currentIndex].textColor)
                    .padding()
                
                HStack {
                    Button {
                        viewModel.textBoxes[viewModel.currentIndex].isAdded = true
                        viewModel.toolPicker.setVisible(true, forFirstResponder: viewModel.canvas)
                        viewModel.canvas.becomeFirstResponder()
                        withAnimation {
                            viewModel.addNewBox = false
                        }
                    } label: {
                        Text("Add")
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.cancelTextView()
                    } label: {
                        Text("Cancel")
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .overlay(
                    HStack(spacing: 15) {
                        ColorPicker("", selection: $viewModel.textBoxes[viewModel.currentIndex].textColor).labelsHidden()
                        
                        Button {
                            viewModel.textBoxes[viewModel.currentIndex].isBold.toggle()
                        } label: {
                            Text(viewModel.textBoxes[viewModel.currentIndex].isBold ? "Normal" : "Bold")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }

                    }
                    
                )
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Message"), message: Text(viewModel.message), dismissButton: .destructive(Text("Ok")))
        }
    }
}

#Preview {
    NavigationStack {
        MainView(showSignInview: .constant(false))
    }
}

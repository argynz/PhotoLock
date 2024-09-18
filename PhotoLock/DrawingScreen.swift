//
//  DrawingScreen.swift
//  PhotoLock
//
//  Created by Argyn on 18.09.2024.
//

import SwiftUI
import PencilKit

struct DrawingScreen: View {
    @EnvironmentObject var viewModel: MainViewModel
    var body: some View {
        ZStack {
            GeometryReader { proxy -> AnyView in
                let size = proxy.frame(in: .global)
                
                DispatchQueue.main.async {
                    if viewModel.rect == .zero{
                        viewModel.rect = size
                    }
                }
        
                return AnyView(
                    
                    ZStack {
                        CanvasView(canvas: $viewModel.canvas, image: $viewModel.selectedImage, toolPicker: $viewModel.toolPicker, rect: size.size)
                        
                        ForEach(viewModel.textBoxes) { box in
                            Text(viewModel.textBoxes[viewModel.currentIndex].id == box.id && viewModel.addNewBox ? "" : box.text)
                                .font(.system(size: 30))
                                .fontWeight(box.isBold ? . bold : .none)
                                .foregroundColor(box.textColor)
                                .offset(box.offset)
                                .gesture(DragGesture().onChanged({ (value) in
                                    let current = value.translation
                                    let lastOffset = box.lastOffSet
                                    let newTranslation = CGSize(width: lastOffset.width + current.width, height: lastOffset.height + current.height)
                                    
                                    viewModel.textBoxes[getIndex(textBox: box)].offset = newTranslation
                                }).onEnded({ (value) in
                                    viewModel.textBoxes[getIndex(textBox: box)].lastOffSet = value.translation
                                })
                                )
                                .onLongPressGesture {
                                    viewModel.toolPicker.setVisible(false, forFirstResponder: viewModel.canvas)
                                    viewModel.canvas.resignFirstResponder()
                                    viewModel.currentIndex = getIndex(textBox: box)
                                    withAnimation{
                                        viewModel.addNewBox = true
                                    }
                                }
                            
                        }
                    }
                )
                
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.saveImage()
                } label: {
                    Text("Save")
                }
                .disabled(viewModel.addNewBox)

            }
            
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.textBoxes.append(TextBox())
                    viewModel.currentIndex = viewModel.textBoxes.count - 1
                    
                    withAnimation {
                        viewModel.addNewBox.toggle()
                    }
                    viewModel.toolPicker.setVisible(false, forFirstResponder: viewModel.canvas)
                    viewModel.canvas.resignFirstResponder()
                } label: {
                    Image(systemName: "text.badge.plus")
                }
                .disabled(viewModel.addNewBox)

            }
        })
    }
    
    func getIndex(textBox: TextBox) -> Int {
        let index = viewModel.textBoxes.firstIndex { (box) -> Bool in
            return textBox.id == box.id
        } ?? 0
        
        return index
    }
}

struct CanvasView: UIViewRepresentable {
    
    @Binding var canvas: PKCanvasView
    @Binding var image: UIImage?
    @Binding var toolPicker: PKToolPicker
    var rect: CGSize
    
    func makeUIView(context: Context) -> PKCanvasView {
        
        canvas.isOpaque = false
        canvas.backgroundColor = .clear
        canvas.drawingPolicy = .anyInput
        
        if image != nil {
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            
            let subView = canvas.subviews[0]
            subView.addSubview(imageView)
            subView.sendSubviewToBack(imageView)
            
            toolPicker.setVisible(true, forFirstResponder: canvas)
            toolPicker.addObserver(canvas)
            canvas.becomeFirstResponder()
        }
        
        return canvas
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

#Preview {
    DrawingScreen()
}

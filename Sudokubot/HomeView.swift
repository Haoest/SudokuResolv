import SwiftUI
import PhotosUI
import UIKit

struct HomeView: View {
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var navigateToPreview: Bool = false
    @State private var capturedImage: UIImage?
    @State private var showingCamera = false
    @State private var showingArchive = false
    @State private var showingHelp = false
    @State private var clipboardHasImage = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.2, green: 0.2, blue: 0.2),
                             Color(red: 0.0, green: 0.0, blue: 0.7)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Sudoku Resolv")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .padding(.top, 40)

                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        menuButton("Open from Photo Library")
                    }

                    Button { showingCamera = true } label: {
                        menuButton("Capture from Camera")
                    }

                    Button {
                        if let img = UIPasteboard.general.image {
                            capturedImage = img
                            navigateToPreview = true
                        }
                    } label: {
                        menuButton("Open from Clipboard")
                    }
                    .disabled(!clipboardHasImage)
                    .opacity(clipboardHasImage ? 1.0 : 0.4)

                    Button {
                        if let img = UIImage(named: "blankSheet") {
                            capturedImage = img
                            navigateToPreview = true
                        }
                    } label: {
                        menuButton("Use Blank Sheet")
                    }

                    Button { showingArchive = true } label: {
                        menuButton("Archive")
                    }

                    Button { showingHelp = true } label: {
                        menuButton("Help")
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationDestination(isPresented: $navigateToPreview) {
                if let img = capturedImage {
                    PreviewView(image: img)
                }
            }
            .navigationDestination(isPresented: $showingArchive) {
                ArchiveView()
            }
            .navigationDestination(isPresented: $showingHelp) {
                HelpView()
            }
            .sheet(isPresented: $showingCamera) {
                CameraPickerView { img in
                    showingCamera = false
                    if let img {
                        capturedImage = img
                        navigateToPreview = true
                    }
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let img = UIImage(data: data) {
                        capturedImage = img
                        navigateToPreview = true
                    }
                }
            }
            .onAppear { clipboardHasImage = UIPasteboard.general.image != nil }
        }
    }

    @ViewBuilder
    private func menuButton(_ title: String) -> some View {
        Text(title)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.15))
            .foregroundStyle(.white)
            .cornerRadius(10)
    }
}

struct CameraPickerView: UIViewControllerRepresentable {
    var onPick: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onPick: (UIImage?) -> Void
        init(onPick: @escaping (UIImage?) -> Void) { self.onPick = onPick }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let img = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
            onPick(img)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onPick(nil)
        }
    }
}

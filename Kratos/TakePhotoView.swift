import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct TakePhotoView: View {
    @ObservedObject var feedViewModel = FeedViewModel()
    @State private var isShowingImagePicker = false // Show the camera interface immediately
    @State private var selectedImage: UIImage? = nil
    @State private var caption: String = ""
    @Binding var selectedTab: Tab // Binding to manage navigation

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    if let selectedImage = selectedImage {
                        Color(red: 0.16, green: 0.18, blue: 0.2)
                            .edgesIgnoringSafeArea(.all)
                        VStack {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: geometry.size.height * 0.3)

                            TextField("Write a caption...", text: $caption)
                                .font(.custom("Marker Felt", size: 18))
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)

                            Button(action: {
                                feedViewModel.uploadPost(image: selectedImage, caption: caption)
                                self.selectedImage = nil
                                self.caption = ""
                                self.isShowingImagePicker = true // Show the camera interface again
                                selectedTab = .home // Navigate to home after posting
                            }) {
                                Text("Post")
                                    .font(.custom("Marker Felt", size: 20))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                    } else {
                        ImagePicker(sourceType: .camera, selectedImage: self.$selectedImage)
                            .edgesIgnoringSafeArea(.all) // Ensure the camera view stretches to the top and bottom edges
                    }
                }
                .navigationBarHidden(true)
                .sheet(isPresented: $isShowingImagePicker, onDismiss: {
                    if selectedImage == nil {
                        selectedTab = .home // Navigate to home if the camera is cancelled
                    }
                }) {
                    ImagePicker(sourceType: .camera, selectedImage: self.$selectedImage)
                        .edgesIgnoringSafeArea(.all)
                }
                .onAppear {
                    isShowingImagePicker = true // Show the camera interface immediately
                }
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .camera
    @Binding var selectedImage: UIImage?

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = false
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true, completion: nil)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

#Preview {
    TakePhotoView(selectedTab: .constant(.home))
}


import SwiftUI
import PhotosUI
import Cloudinary

struct NewPostView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var imagePicker = ImagePicker()
    @State private var postMessage = ""
    @State private var uploadedPostPublicId: String?
    @State private var showPostSuccesfulText = false
    @State private var shouldNavToHomePage = false
    
    let cloudinary = CLDCloudinary(configuration: CloudinaryConfig.configuration)
    
    var body: some View {
        
            VStack(alignment: .center) {

                TextField("What do you want to say...", text: $postMessage)
                    .padding()
                    .multilineTextAlignment(.center)
                    .navigationTitle("New post")
                
                if let uploadedPostPublicId = uploadedPostPublicId {
                    cloudinaryImageView(cloudinary: cloudinary, imagePath: uploadedPostPublicId)
                        .frame(maxHeight: 200) // Adjust height as needed
                        .scaledToFit()
                            }
                
                
                PhotosPicker(selection: $imagePicker.imageSelection) {
                    Text("Upload a photo")
                }
                .onChange(of: imagePicker.imageData) { imageData in
                    // This block is executed when image data is set in the ImagePicker
                    // You can update the uploadedImagePublicId here
                    if let imageData = imageData {
                        imagePicker.uploadToCloudinary(data: imageData) { imagePublicId in
                            if let imagePublicId = imagePublicId {
                                uploadedPostPublicId = imagePublicId
                            } else { /*look here later*/
                                print("Error: Image upload failed.")
                            }
                        }
                    }
                }


                Button("Submit") {
                    submitPost()
                    shouldNavToHomePage = true
                }
                .background(NavigationLink(destination: HomePageTestView(), isActive: $shouldNavToHomePage) {
                    EmptyView()
                })
                
                .padding()
                
                if showPostSuccesfulText {
                    Text("Post successful")
                        .foregroundColor(.green)
                        .padding(.top, 20)
                }

            }
            .padding()
            .onAppear {
                showPostSuccesfulText = false
            }
        }
    
                        


    func submitPost() {
        guard !postMessage.isEmpty else {
            // Alert if we want it.
            return
        }

        let postEndpoint = "http://127.0.0.1:8080/posts"
        var postData = [
            "message": postMessage
            // userID?
        ]
        
        if let uploadedPostPublicId = uploadedPostPublicId {
                postData["publicID"] = uploadedPostPublicId
            }

        guard let url = URL(string: postEndpoint) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let userToken = try? KeychainHelper.loadToken() else {
            print("Failed to load user token")
            return
        }

        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postData)
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error submitting post: \(error)")
                return
            }

         
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Code: \(httpResponse.statusCode)")
            }

            DispatchQueue.main.async {
                
                postMessage = ""
                showPostSuccesfulText = true
                print("Post submitted successfully")
                
            }
            
        }.resume()
    }
}

struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
        NewPostView()
    }
}

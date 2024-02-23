//
// AuthenticationService.swift
// MobileAcebook
//
// Created by Josué Estévez Fernández on 01/10/2023.
//

import Foundation

public struct LoginResponse: Codable {
    var token: String
    var message: String
    var user: String
}

public struct LoginError: Error {
    var localizedDescription: String
}


class AuthenticationService: ObservableObject, AuthenticationServiceProtocol {
    @Published var isLoggedIn: Bool = false
    @Published var userId: String = ""
    
    func signUp(user: User, confPassword: String, completion: @escaping (Bool, String?) -> Void) {
        var canSignUp = false
        var errorMessage: String? = nil

        let username = user.username
        let email = user.email
        let password = user.password
        
        let validUsername = isUsernameValid(username)
        let validEmail = isEmailValid(email)
        let passwordsMatch = doPasswordsMatch(password, confPassword)
        let validPassword = isPasswordValid(password)

        if validUsername && validEmail && passwordsMatch && validPassword {
            createUser(user: user) { result in
                switch result {
                case .success(let data):
                    print("User has been created: \(data)")
                    canSignUp = true
                    completion(canSignUp, errorMessage)
                case .failure(let error):
                    print("Error creating user: \(error)")
                    canSignUp = false
                    errorMessage = "Error creating user. Email has already been taken. Please try again."
                    completion(canSignUp, errorMessage)
                }
            }
        } else {
            var errorMessages: [String] = []

            if !validUsername {
                errorMessages.append("Invalid username.")
            }
            
            if !validEmail {
                errorMessages.append("Invalid email.")
            }

            if !passwordsMatch {
                errorMessages.append("Passwords do not match.")
            }

            if !validPassword {
                errorMessages.append("Password must be at least 8 characters long.\nPassword must contain at least 1 upper case and 1 lower case letter.\nPassword must contain at least 1 number.\nPassword must contain at least 1 special character (?!#%)")
            }

            errorMessage = errorMessages.joined(separator: "\n")
            completion(false, errorMessage)
        }
    }
    
    func isUsernameValid(_ username: String) -> Bool {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedUsername.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    func isEmailValid(_ email: String) -> Bool {
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Za-z0-9._%+-]+@[A-Za-z0-9._%+-]+\\.[A-Za-z]{2,}")
        return emailPredicate.evaluate(with: email)
    }
    
    func doPasswordsMatch(_ password: String, _ confPassword: String) -> Bool {
        if password == confPassword {
            return true
        } else {
            return false
        }
    }
    
    func isPasswordValid(_ password: String) -> Bool {
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$")
        return passwordPredicate.evaluate(with: password)
    }

    
    func logIn(email: String, password: String, completion: @escaping(Result<Void, LoginError>) -> Void) {
        let requestBody = ["email": email, "password": password]
        
        guard let encoded = try? JSONEncoder().encode(requestBody) else {
                  completion(.failure(LoginError(localizedDescription: "Failed to encode request body")))
                  return
              }
        
        let url = URL(string: "http://127.0.0.1:8080/tokens")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        
        URLSession.shared.uploadTask(with: request, from: encoded) {data, response, error in
            if let error = error {
                completion(.failure(LoginError(localizedDescription: "Log In failed: \(error.localizedDescription)")))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(LoginError(localizedDescription: "Unexpected response format")))
                return
            }
            
            switch httpResponse.statusCode {
                    case 201:
                if let data = data, let decodedResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                    DispatchQueue.main.async {
                        do {
                            try KeychainHelper.saveToken(decodedResponse.token)
                            self.userId = decodedResponse.user
                            self.isLoggedIn = true
                            completion(.success(()))
                        } catch {
                            completion(.failure(LoginError(localizedDescription: "Failed to save token: \(error.localizedDescription)")))
                        }
                    }
                        }
                    case 401:
                        completion(.failure(LoginError(localizedDescription: "Email not found")))

                    case 402:
                        completion(.failure(LoginError(localizedDescription: "Incorrect password")))

                    default:
                        completion(.failure(LoginError(localizedDescription: "Unhandled status code: \(httpResponse.statusCode)")))
                    }
            
        }.resume()
        
    }
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try KeychainHelper.deleteToken()
            isLoggedIn = false
            completion(.success(()))
        } catch {
            print("failed to signout, can't delete token")
            completion(.failure(error))
        }
    }
    
    //ensures that there is only one instance of the AuthenticationService class throughout the application
    static let shared = AuthenticationService()
    // Private initializer to enforce singleton pattern
    private init() {
        
    }
}


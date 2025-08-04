//
//  ProfileService.swift
//  ExpenseBuddy
//
//  Created by RajPratapSingh on 01/08/25.
//

import Foundation
import Supabase

final class ProfileService: ObservableObject {
    static let shared = ProfileService()
    
    private let client = SupabaseAuthService.shared.client
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {}
    
    // MARK: - Create Profile
    func createProfile(_ profile: Profile) async throws -> Profile {
        isLoading = true
        defer { isLoading = false }
        
        let dateFormatter = ISO8601DateFormatter()
        
        struct ProfileInsert: Codable {
            let id: String
            let email: String
            let first_name: String
            let last_name: String
            let phone_number: String?
            let date_of_birth: String?
            let profile_image_url: String?
            let currency: String
            let timezone: String
            let created_at: String
            let updated_at: String
        }
        
        let profileInsert = ProfileInsert(
            id: profile.id,
            email: profile.email,
            first_name: profile.firstName,
            last_name: profile.lastName,
            phone_number: profile.phoneNumber,
            date_of_birth: profile.dateOfBirth != nil ? dateFormatter.string(from: profile.dateOfBirth!) : nil,
            profile_image_url: profile.profileImageUrl,
            currency: profile.currency,
            timezone: profile.timezone,
            created_at: dateFormatter.string(from: profile.createdAt),
            updated_at: dateFormatter.string(from: profile.updatedAt)
        )
        
        do {
            let response: ProfileResponse = try await client
                .from("profiles")
                .insert(profileInsert)
                .select()
                .single()
                .execute()
                .value
            
            return response.toProfile()
        } catch {
            errorMessage = "Failed to create profile: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Read Profile
    func fetchProfile(for userId: String) async throws -> Profile {
        print("👤 Fetching profile for user: \(userId)")
        isLoading = true
        defer { isLoading = false }
        
        do {
            print("🔍 Executing Supabase query for profiles table...")
            let response: ProfileResponse = try await client
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            
            let profile = response.toProfile()
            print("✅ Fetched profile: \(profile.fullName) (\(profile.email))")
            return profile
        } catch {
            print("❌ Failed to fetch profile: \(error.localizedDescription)")
            print("❌ Full error: \(error)")
            errorMessage = "Failed to fetch profile: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Update Profile
    func updateProfile(_ profile: Profile) async throws -> Profile {
        isLoading = true
        defer { isLoading = false }
        
        let dateFormatter = ISO8601DateFormatter()
        let updatedAt = Date()
        
        struct ProfileUpdate: Codable {
            let first_name: String
            let last_name: String
            let phone_number: String?
            let date_of_birth: String?
            let profile_image_url: String?
            let currency: String
            let timezone: String
            let updated_at: String
        }
        
        let profileUpdate = ProfileUpdate(
            first_name: profile.firstName,
            last_name: profile.lastName,
            phone_number: profile.phoneNumber,
            date_of_birth: profile.dateOfBirth != nil ? dateFormatter.string(from: profile.dateOfBirth!) : nil,
            profile_image_url: profile.profileImageUrl,
            currency: profile.currency,
            timezone: profile.timezone,
            updated_at: dateFormatter.string(from: updatedAt)
        )
        
        do {
            let response: ProfileResponse = try await client
                .from("profiles")
                .update(profileUpdate)
                .eq("id", value: profile.id)
                .select()
                .single()
                .execute()
                .value
            
            return response.toProfile()
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Delete Profile
    func deleteProfile(id: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await client
                .from("profiles")
                .delete()
                .eq("id", value: id)
                .execute()
        } catch {
            errorMessage = "Failed to delete profile: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Upload Profile Image
    func uploadProfileImage(userId: String, imageData: Data) async throws -> String {
        isLoading = true
        defer { isLoading = false }
        
        let fileName = "\(userId)_\(UUID().uuidString).jpg"
        let filePath = "profile-images/\(fileName)"
        
        do {
            try await client.storage
                .from("avatars")
                .upload(
                    path: filePath,
                    file: imageData,
                    options: FileOptions(contentType: "image/jpeg")
                )
            
            let publicURL = try client.storage
                .from("avatars")
                .getPublicURL(path: filePath)
            
            return publicURL.absoluteString
        } catch {
            errorMessage = "Failed to upload profile image: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Delete Profile Image
    func deleteProfileImage(userId: String, imageUrl: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Extract file path from URL
        guard let url = URL(string: imageUrl),
              let fileName = url.lastPathComponent.components(separatedBy: "/").last else {
            throw NSError(domain: "ProfileService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid image URL"])
        }
        
        let filePath = "profile-images/\(fileName)"
        
        do {
            try await client.storage
                .from("avatars")
                .remove(paths: [filePath])
        } catch {
            errorMessage = "Failed to delete profile image: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Check if Profile Exists
    func profileExists(for userId: String) async throws -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: [ProfileResponse] = try await client
                .from("profiles")
                .select("id")
                .eq("id", value: userId)
                .execute()
                .value
            
            return !response.isEmpty
        } catch {
            errorMessage = "Failed to check profile existence: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Get Profile by Email
    func fetchProfileByEmail(email: String) async throws -> Profile? {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: [ProfileResponse] = try await client
                .from("profiles")
                .select()
                .eq("email", value: email)
                .execute()
                .value
            
            return response.first?.toProfile()
        } catch {
            errorMessage = "Failed to fetch profile by email: \(error.localizedDescription)"
            throw error
        }
    }
} 

import SwiftUI
import CoreData

enum HistoryStore {
    static func saveAttempt(
        context: NSManagedObjectContext,
        bird: Birdle,
        tries: Int,
        duration: TimeInterval,
        success: Bool,
        finalImage: UIImage?
    ) {
        let a = Attempt(context: context)
        a.date = Date()
        a.name = bird.name
        a.tries = Int16(tries)
        a.seconds = duration
        a.success = success
        a.imageID = bird.image
        a.photographer = bird.photographer
        a.license = bird.license
        a.birdLink = bird.bird_link
        if let img = finalImage, let jpg = img.jpegData(compressionQuality: 0.9) {
            a.photoData = jpg
        }
        try? context.save()
    }
}

// Helpers for one full run per bird
private let attemptedKey = "attemptedImageIDs"

func hasAttempted(imageID: String) -> Bool {
    let set = Set(UserDefaults.standard.stringArray(forKey: attemptedKey) ?? [])
    return set.contains(imageID)
}

func markAttempted(imageID: String) {
    var arr = UserDefaults.standard.stringArray(forKey: attemptedKey) ?? []
    if !arr.contains(imageID) { arr.append(imageID) }
    UserDefaults.standard.set(arr, forKey: attemptedKey)
}

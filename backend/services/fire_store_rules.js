rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /inventory/{itemId} {
        allow create: if request.auth.uid == userId;
        allow read, update, delete: if request.auth.uid == resource.data.owner_id;
      }
    }
  }
}
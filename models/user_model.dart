// Conceptual representation of the User Profile data
// This would be stored in Firestore in a 'users' collection,
// with the document ID being the Firebase Auth UID.

class UserProfile {
  final String uid; // Firebase Authentication User ID
  String username; // Display name, chosen by user, needs to be unique or handled
  final String email; // Email used for registration/login
  DateTime createdAt; // Timestamp of account creation

  // Privacy settings
  String locationVisibility; // e.g., "public", "friends", "private"
  String ageVisibility; // e.g., "public", "friends", "private"
  String performanceLevelVisibility; // e.g., "public", "friends", "private"
  String activityFeedVisibility; // e.g., "public", "friends", "private"

  // Anonymity Modes
  bool isGhostModeActive;
  bool isSoloModeActive; // May overlap with other settings
  bool isProfileLocked; // Overarching privacy lock

  // Consents
  bool consentsToResearchDataUse;
  DateTime? researchConsentTimestamp;
  bool consentsToShopSponsorDataSharing;
  DateTime? shopSponsorConsentTimestamp;

  // Social features
  List<String> friendUids; // List of UIDs of accepted friends
  List<String> blockedUserUids; // List of UIDs of users blocked by this user
  // Add other fields like profilePictureUrl, bio etc. as needed

  UserProfile({
    required this.uid,
    required this.username,
    required this.email,
    required this.createdAt,
    this.locationVisibility = "private", // Default to private
    this.ageVisibility = "private",
    this.performanceLevelVisibility = "private",
    this.activityFeedVisibility = "friends", // Default to friends for social aspect
    this.isGhostModeActive = false,
    this.isSoloModeActive = false,
    this.isProfileLocked = false,
    this.consentsToResearchDataUse = false,
    this.researchConsentTimestamp,
    this.consentsToShopSponsorDataSharing = false,
    this.shopSponsorConsentTimestamp,
    this.friendUids = const [], // Initialize with empty list
    this.blockedUserUids = const [], // Initialize with empty list
  });

  // Method to convert a UserProfile object to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid, // Can be redundant if doc ID is uid, but good for queries
      'username': username,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'locationVisibility': locationVisibility,
      'ageVisibility': ageVisibility,
      'performanceLevelVisibility': performanceLevelVisibility,
      'activityFeedVisibility': activityFeedVisibility,
      'isGhostModeActive': isGhostModeActive,
      'isSoloModeActive': isSoloModeActive,
      'isProfileLocked': isProfileLocked,
      'consentsToResearchDataUse': consentsToResearchDataUse,
      'researchConsentTimestamp': researchConsentTimestamp?.toIso8601String(),
      'consentsToShopSponsorDataSharing': consentsToShopSponsorDataSharing,
      'shopSponsorConsentTimestamp': shopSponsorConsentTimestamp?.toIso8601String(),
      'friendUids': friendUids,
      'blockedUserUids': blockedUserUids,
    };
  }

  // Factory constructor to create a UserProfile from a Firestore DocumentSnapshot
  factory UserProfile.fromFirestore(Map<String, dynamic> data, String documentId) {
    return UserProfile(
      uid: documentId,
      username: data['username'] as String,
      email: data['email'] as String,
      createdAt: DateTime.parse(data['createdAt'] as String),
      locationVisibility: data['locationVisibility'] as String? ?? 'private',
      ageVisibility: data['ageVisibility'] as String? ?? 'private',
      performanceLevelVisibility: data['performanceLevelVisibility'] as String? ?? 'private',
      activityFeedVisibility: data['activityFeedVisibility'] as String? ?? 'friends',
      isGhostModeActive: data['isGhostModeActive'] as bool? ?? false,
      isSoloModeActive: data['isSoloModeActive'] as bool? ?? false,
      isProfileLocked: data['isProfileLocked'] as bool? ?? false,
      consentsToResearchDataUse: data['consentsToResearchDataUse'] as bool? ?? false,
      researchConsentTimestamp: data['researchConsentTimestamp'] != null
          ? DateTime.parse(data['researchConsentTimestamp'] as String)
          : null,
      consentsToShopSponsorDataSharing: data['consentsToShopSponsorDataSharing'] as bool? ?? false,
      shopSponsorConsentTimestamp: data['shopSponsorConsentTimestamp'] != null
          ? DateTime.parse(data['shopSponsorConsentTimestamp'] as String)
          : null,
      friendUids: List<String>.from(data['friendUids'] as List<dynamic>? ?? []),
      blockedUserUids: List<String>.from(data['blockedUserUids'] as List<dynamic>? ?? []),
    );
  }
}

// Enums for visibility could be defined for better type safety:
// enum VisibilitySetting { public, friends, private }

/*
 Firestore structure for 'users' collection will now include these new fields, e.g.:
 /users/{auth_uid}
    - ... (existing fields)
    - locationVisibility: "private"
    - ageVisibility: "private"
    - performanceLevelVisibility: "friends"
    - activityFeedVisibility: "friends"
    - isGhostModeActive: false
    - isSoloModeActive: false
    - isProfileLocked: false
    - consentsToResearchDataUse: false
    - researchConsentTimestamp: null
    - consentsToShopSponsorDataSharing: false
    - shopSponsorConsentTimestamp: null
    // ... other profile fields
*/

/*
 Firestore structure for 'usernames' collection (for uniqueness check):
 /usernames/{username_lowercase}
    - uid: "user_auth_id_owning_this_username"
*/

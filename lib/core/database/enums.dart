/// Lifecycle of a screenshot inside the processing pipeline.
enum ProcessingStatus { pending, processing, completed, failed }

enum ScreenshotSource { picker, share, backup }

enum EntityType {
  email,
  phone,
  url,
  date,
  time,
  amount,
  deadline,
  flightReference,
  orderReference,
  address,
  productName,
  eventTitle,
  wifiCredentials,
  codeSnippet,
}

/// Whether an extracted value can be trusted as-is.
enum ValidationStatus { valid, needsConfirmation, confirmed, rejected }

enum ReminderStatus { scheduled, completed, cancelled }

enum RepeatRule { none, daily, weekly, monthly }

enum ActionType {
  createReminder,
  addCalendarEvent,
  addToWishlist,
  openUrl,
  callPhone,
  saveContact,
  sendEmail,
  openMap,
  saveTransaction,
  saveTravel,
  saveNotes,
  copyWifi,
  copyCode,
}

enum ActionStatus { suggested, accepted, dismissed, postponed }

enum JobType { process }

enum JobStatus { queued, running, done, failed }

import CoreData

protocol TrackerRecordStoreProtocol {
    func addRecord(_ record: TrackerRecord)
}

final class TrackerRecordStore {
    private let dataController = DataController.shared
    private let context = DataController.shared.context
}

// MARK: - TrackerRecordStoreProtocol
extension TrackerRecordStore: TrackerRecordStoreProtocol {
    func addRecord(_ record: TrackerRecord) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", record.trackerId as CVarArg)
        
        let results = try? context.fetch(fetchRequest)
        
        guard let trackerCoreData = results?.first else {
            return
        }
        
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.date = record.date
        trackerRecordCoreData.tracker = trackerCoreData
        
        dataController.saveContext()
    }
}

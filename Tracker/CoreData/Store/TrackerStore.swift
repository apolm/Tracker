import UIKit
import CoreData

struct TrackerStoreUpdate {
    let insertedSections: [Int]
    let deletedSections: [Int]
    let insertedIndices: [IndexPath]
    let deletedIndices: [IndexPath]
    let updatedIndices: [IndexPath]
    let movedIndices: [(from: IndexPath, to: IndexPath)]
}

struct TrackerCompletion {
    let tracker: Tracker
    let numberOfCompletions: Int
    let isCompleted: Bool
    let isPinned: Bool
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

protocol TrackerStoreProtocol {
    var isFilteredEmpty: Bool { get }
    var isDateEmpty: Bool { get }
    
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func sectionName(for section: Int) -> String
    
    func addTracker(_ tracker: Tracker, to category: TrackerCategory)
    func updateTracker(_ tracker: Tracker, with category: TrackerCategory)
    func deleteTracker(at indexPath: IndexPath)
    func pinTracker(at indexPath: IndexPath)
    func unpinTracker(at indexPath: IndexPath)
    
    func completionStatus(for indexPath: IndexPath) -> TrackerCompletion
    func categoryName(for indexPath: IndexPath) -> String
    func applyFilter(_ filter: TrackerFilterOption, on date: Date)
    func changeCompletion(for indexPath: IndexPath, to isCompleted: Bool)
}

final class TrackerStore: NSObject {
    private weak var delegate: TrackerStoreDelegate?
    private var date: Date
    private var filter: TrackerFilterOption
    
    private let dataController = DataController.shared
    private let context = DataController.shared.context
    private let categoryProvider: TrackerCategoryCoreDataProvider
    
    private var insertedSections: [Int] = []
    private var deletedSections: [Int] = []
    private var insertedIndices: [IndexPath] = []
    private var deletedIndices: [IndexPath] = []
    private var updatedIndices: [IndexPath] = []
    private var movedIndices: [(from: IndexPath, to: IndexPath)] = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category.order", ascending: true),
                                        NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = fetchPredicate()
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: "category.order",
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(delegate: TrackerStoreDelegate, date: Date, filter: TrackerFilterOption, categoryProvider: TrackerCategoryCoreDataProvider? = nil) {
        self.delegate = delegate
        self.date = date
        self.filter = filter
        if let categoryProvider {
            self.categoryProvider = categoryProvider
        } else {
            self.categoryProvider = TrackerCategoryStore(delegate: nil)
        }
    }
    
    private func fetchPredicate() -> NSPredicate {
        switch filter {
        case .all, .today:
            return allTrackersFetchPredicate()
        case .completed:
            return completedTrackersFetchPredicate()
        case .uncompleted:
            return uncompletedTrackersFetchPredicate()
        }
    }
    
    private func allTrackersFetchPredicate() -> NSPredicate {
        let scheduleMatchDate = NSPredicate(
            format: "%K CONTAINS[n] %@",
            #keyPath(TrackerCoreData.daysRaw),
            String(Weekday(date: date).rawValue))
        
        let completionMatchDate = NSPredicate(
            format: "SUBQUERY(%K, $record, $record != nil AND $record.date == %@).@count > 0",
            #keyPath(TrackerCoreData.records),
            date as NSDate)
        
        let isIrregular = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCoreData.daysRaw),
            "")
        
        let isNotCompletedEver = NSPredicate(
            format: "SUBQUERY(%K, $record, $record != nil).@count == 0",
            #keyPath(TrackerCoreData.records))
        
        let isNotCompletedIrregular = NSCompoundPredicate(
            andPredicateWithSubpredicates: [isIrregular, isNotCompletedEver])
        
        let finalPredicate = NSCompoundPredicate(
            orPredicateWithSubpredicates: [scheduleMatchDate, completionMatchDate, isNotCompletedIrregular])
        
        return finalPredicate
    }
    
    private func completedTrackersFetchPredicate() -> NSPredicate {
        let completionMatchDate = NSPredicate(
            format: "SUBQUERY(%K, $record, $record != nil AND $record.date == %@).@count > 0",
            #keyPath(TrackerCoreData.records),
            date as NSDate)
        
        return completionMatchDate
    }
    
    private func uncompletedTrackersFetchPredicate() -> NSPredicate {
        let isNotCompletedAtDate = NSPredicate(
            format: "SUBQUERY(%K, $record, $record != nil AND $record.date == %@).@count == 0",
            #keyPath(TrackerCoreData.records),
            date as NSDate)
        
        let scheduleMatchDate = NSPredicate(
            format: "%K CONTAINS[n] %@",
            #keyPath(TrackerCoreData.daysRaw),
            String(Weekday(date: date).rawValue))
        
        let isNotCompletedRegular = NSCompoundPredicate(
            andPredicateWithSubpredicates: [isNotCompletedAtDate, scheduleMatchDate])
        
        let isIrregular = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCoreData.daysRaw),
            "")
        
        let isNotCompletedEver = NSPredicate(
            format: "SUBQUERY(%K, $record, $record != nil).@count == 0",
            #keyPath(TrackerCoreData.records))
        
        let isNotCompletedIrregular = NSCompoundPredicate(
            andPredicateWithSubpredicates: [isIrregular, isNotCompletedEver])
        
        let finalPredicate = NSCompoundPredicate(
            orPredicateWithSubpredicates: [isNotCompletedRegular, isNotCompletedIrregular])
        
        return finalPredicate
    }
    
    private func fetchTrackerByID(_ id: UUID) -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        return try? context.fetch(fetchRequest).first
    }
}

// MARK: - TrackerStoreProtocol
extension TrackerStore: TrackerStoreProtocol {
    var isFilteredEmpty: Bool {
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            return fetchedObjects.isEmpty
        } else {
            return true
        }
    }
    
    var isDateEmpty: Bool {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = allTrackersFetchPredicate()
        fetchRequest.fetchLimit = 1
        
        return (try? context.fetch(fetchRequest))?.isEmpty ?? true
    }
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func sectionName(for section: Int) -> String {
        let order = fetchedResultsController.sections?[section].name ?? ""
        return categoryProvider.categoryName(from: order)
    }
    
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) {
        let categoryCoreData = categoryProvider.fetchOrCreateCategory(category.name)
        
        let trackerCoreData = TrackerCoreData(context: context)
        
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.colorHex = tracker.color.toHex()
        trackerCoreData.daysRaw = tracker.days?.toRawString() ?? ""
        trackerCoreData.category = categoryCoreData
        
        dataController.saveContext()
    }
    
    func updateTracker(_ tracker: Tracker, with category: TrackerCategory) {
        guard let trackerCoreData = fetchTrackerByID(tracker.id) else { return }
        
        let categoryCoreData = categoryProvider.fetchOrCreateCategory(category.name)
        
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.colorHex = tracker.color.toHex()
        trackerCoreData.daysRaw = tracker.days?.toRawString() ?? ""
        
        if trackerCoreData.category?.isPinned ?? false {
            trackerCoreData.categoryBeforePin = categoryCoreData
        } else {
            trackerCoreData.category = categoryCoreData
        }
        
        dataController.saveContext()
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        context.delete(trackerCoreData)
        dataController.saveContext()
    }
    
    func pinTracker(at indexPath: IndexPath) {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        
        guard let category = trackerCoreData.category, !category.isPinned else { return }
        
        let pinnedCategory = categoryProvider.fetchOrCreatePinnedCategory()
        
        trackerCoreData.categoryBeforePin = trackerCoreData.category
        trackerCoreData.category = pinnedCategory
        
        dataController.saveContext()
    }
    
    func unpinTracker(at indexPath: IndexPath) {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        
        guard let _ = trackerCoreData.categoryBeforePin else { return }
        
        trackerCoreData.category = trackerCoreData.categoryBeforePin
        trackerCoreData.categoryBeforePin = nil
        
        dataController.saveContext()
    }
    
    func completionStatus(for indexPath: IndexPath) -> TrackerCompletion {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        
        let tracker = Tracker(id: trackerCoreData.id ?? UUID(),
                              name: trackerCoreData.name ?? "",
                              color: UIColor(hex: trackerCoreData.colorHex ?? "#000000") ?? .clear,
                              emoji: trackerCoreData.emoji ?? "",
                              days: Set(rawValue: trackerCoreData.daysRaw))
        
        let isCompleted = trackerCoreData.records?.contains { record in
            guard let trackerRecord = record as? TrackerRecordCoreData else { return false }
            return trackerRecord.date == date
        } ?? false
        
        let trackerCompletion = TrackerCompletion(tracker: tracker,
                                                  numberOfCompletions: trackerCoreData.records?.count ?? 0,
                                                  isCompleted: isCompleted,
                                                  isPinned: trackerCoreData.category?.isPinned ?? false)
        return trackerCompletion
    }
    
    func categoryName(for indexPath: IndexPath) -> String {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        
        if trackerCoreData.category?.isPinned ?? false {
            return trackerCoreData.categoryBeforePin?.name ?? ""
        } else {
            return trackerCoreData.category?.name ?? ""
        }
    }
    
    func applyFilter(_ filter: TrackerFilterOption, on date: Date) {
        self.filter = filter
        self.date = date
        
        fetchedResultsController.fetchRequest.predicate = fetchPredicate()
        try? fetchedResultsController.performFetch()
    }
    
    func changeCompletion(for indexPath: IndexPath, to isCompleted: Bool) {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        
        let existingRecord = trackerCoreData.records?.first { record in
            if let trackerRecord = record as? TrackerRecordCoreData,
               let trackerDate = trackerRecord.date {
                return trackerDate == date
            } else {
                return false
            }
        }
        
        if isCompleted && existingRecord == nil {
            let trackerRecordCoreData = TrackerRecordCoreData(context: context)
            trackerRecordCoreData.date = date
            trackerRecordCoreData.tracker = trackerCoreData
            
            dataController.saveContext()
        } else if !isCompleted,
                  let trackerRecordCoreData = existingRecord as? TrackerRecordCoreData {
            context.delete(trackerRecordCoreData)
            dataController.saveContext()
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedSections.removeAll()
        deletedSections.removeAll()
        insertedIndices.removeAll()
        deletedIndices.removeAll()
        updatedIndices.removeAll()
        movedIndices.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertedSections.append(sectionIndex)
        case .delete:
            deletedSections.append(sectionIndex)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath {
                deletedIndices.append(indexPath)
            }
        case .insert:
            if let newIndexPath {
                insertedIndices.append(newIndexPath)
            }
        case .update:
            if let indexPath {
                updatedIndices.append(indexPath)
            }
        case .move:
            if let oldIndexPath = indexPath, let newIndexPath = newIndexPath {
                movedIndices.append((from: oldIndexPath, to: newIndexPath))
            }
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let update = TrackerStoreUpdate(
            insertedSections: insertedSections,
            deletedSections: deletedSections,
            insertedIndices: insertedIndices,
            deletedIndices: deletedIndices,
            updatedIndices: updatedIndices,
            movedIndices: movedIndices
        )
        delegate?.didUpdate(update)
    }
}

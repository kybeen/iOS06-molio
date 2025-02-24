import XCTest
import CoreData
@testable import Molio

final class DefaultPlaylistRepositoryTests: XCTestCase {
    var repository: DefaultPlaylistRepository!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        context = TestPersistenceManager.shared.context
        repository = DefaultPlaylistRepository(context: context)
        
    }
    
    override func tearDown() {
        repository = nil
        context = nil
        super.tearDown()
    }
    
    func testSaveNewPlaylist() {
        let playlistName: String = "TestPlaylist"
        
        repository.saveNewPlaylist(playlistName)
        
        let fetchRequest: NSFetchRequest<MolioPlaylist> = MolioPlaylist.fetchRequest()
        
        let playlist = repository.fetchPlaylist(for: playlistName)
        
        XCTAssertEqual(playlist?.name, playlistName)
    }
    
    func testAddMusic() {
        let playlistName: String = "AddMusicPlaylist"
        let testISRC = "TEST_ISRC"
        
        repository.saveNewPlaylist(playlistName)
        repository.addMusic(isrc: testISRC, to: playlistName)
        
        
        guard let playlist = repository.fetchPlaylist(for: playlistName)else {
            return }
        
        let musics = playlist.musics
        
        XCTAssertEqual(musics.count, 1)
        XCTAssertEqual(musics.first, testISRC)
    }
    
    func testDeleteMusic() {
        let playlistName: String = "AddMusicPlaylist"
        let testISRC = "TEST_ISRC"
        
        repository.addMusic(isrc: testISRC, to: playlistName)
        repository.deleteMusic(isrc: testISRC, in: playlistName)
        
        let musics = repository.fetchPlaylist(for: playlistName)?.musics
        XCTAssertTrue(musics?.isEmpty ?? false)
    }
    
    func testFetchMusics() {
        let playlistName: String = "FetchMusicsPlaylist"
        repository.saveNewPlaylist(playlistName)
        
        repository.addMusic(isrc: "MUSIC_1", to: playlistName)
        repository.addMusic(isrc: "MUSIC_2", to: playlistName)

        let musics = repository.fetchPlaylist(for: playlistName)?.musics
        XCTAssertEqual(musics?.count, 2)
        XCTAssertEqual(musics?[0], "MUSIC_1")
        XCTAssertEqual(musics?[1], "MUSIC_2")
    }
    
    func testMoveMusic() {
        let playlistName: String = "MoveMusicPlaylist"
        repository.saveNewPlaylist(playlistName)

        repository.addMusic(isrc: "MUSIC_1", to: playlistName)
        repository.addMusic(isrc: "MUSIC_2", to: playlistName)

        repository.moveMusic(isrc: "MUSIC_1", in: playlistName, fromIndex: 0, toIndex: 1)

        let musics = repository.fetchPlaylist(for: playlistName)?.musics
        XCTAssertEqual(musics?[0], "MUSIC_2")
        XCTAssertEqual(musics?[1], "MUSIC_1")
    }
    
    
    func testDeletePlaylist() {
        let playlistName: String = "DeletePlaylist"
        repository.saveNewPlaylist(playlistName)
        let id = repository.fetchPlaylist(for: playlistName)?.id
        print(id ?? "nil")

        repository.deletePlaylist(playlistName)
        let currId = repository.fetchPlaylist(for: playlistName)?.id

        XCTAssertEqual(currId, nil)

    }
}

final class TestPersistenceManager {
    static let shared = TestPersistenceManager()
    private init() {}
    
    lazy var context: NSManagedObjectContext = {
        let persistentContainer = NSPersistentContainer(name: "MolioModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType // 인메모리로 설정
        persistentContainer.persistentStoreDescriptions = [description]
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load in-memory Core Data stack: \(error)")
            }
        }
        return persistentContainer.viewContext
    }()
}


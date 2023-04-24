//
//  SwiftUIView.swift
//  Moodient
//
//  Created by Smay on 4/24/23.
//

import SwiftUI

struct BackupView: View {
    
    let fileDir: URL?
    
    @State private var files: [URL] = []
    @State private var dirs: [URL] = []
    
    var body: some View {
        Form {
            Section("Files") {
                ForEach(files, id: \.self) { url in
                    Button {
                        
                        MoodEventStorage.moodEventStore.saveBackup()
                        
                        if let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                            let dirPath = documentsDir.appendingPathComponent(MoodEventStorage.DIR_MOOD_EVENTS_DB)
                            
                            do {
                                try FileManager.default.createDirectory(atPath: dirPath.path, withIntermediateDirectories: true, attributes: nil)
                                let databaseFilePath = dirPath.appendingPathComponent(MoodEventStorage.DB_NAME)
                                
                                try FileManager.default.copyItem(at: url, to: databaseFilePath)
                                
                                
                                print("Database sucessfully restored: \(databaseFilePath)")
                            } catch {
                                print("Database backup error: \(error)")
                            }
                        } else {
                            print("Documents directory unknown")
                        }
                    } label: {
                        Text(url.lastPathComponent)
                    }

                    
                }
            }
            Section("Folders") {
                ForEach(dirs, id: \.self) { url in
                    NavigationLink {
                        BackupView(fileDir: url)
                    } label: {
                        Text(url.lastPathComponent)
                    }

                }
            }
        }
        .task {
            loadBackupFileList()
        }
    }
    
    /// https://stackoverflow.com/a/55697010
    func loadBackupFileList() {
        
        let resourceKeys: [URLResourceKey] = [.isDirectoryKey, .contentTypeKey]
        
        guard let fileDir = fileDir else {
            print("File directory is nil")
            return
        }
        let enumerator = FileManager.default.enumerator(at: fileDir, includingPropertiesForKeys: resourceKeys, errorHandler: { url, error in
            print(error)
            return true
        })!
        
        while let fileURL = enumerator.nextObject() as? URL {
            
            guard let fileType = try? fileURL.resourceValues(forKeys: [.isDirectoryKey]) else {
                print("Error processing file \(fileURL)")
                return
            }
            
            if fileType.isDirectory ?? true {
                guard !dirs.contains(fileURL) else {
                    continue
                }
                dirs.append(fileURL)
            } else {
                guard !files.contains(fileURL) else {
                    continue
                }
                files.append(fileURL)
            }
        }
        
    }
}

struct BackupView_Previews: PreviewProvider {
    static var previews: some View {
        BackupView(fileDir: nil)
    }
}

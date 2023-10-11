//
//  ModelManager.m
//  CodeData
//
//  Created by NuSiuKei on 2023/10/2.
//

#import "CoreDataManager.h"
#import <CoreData/NSPersistentContainer.h>
#import <CoreData/NSEntityDescription.h>
#import <CoreData/NSFetchRequest.h>
#import <CoreData/NSPropertyDescription.h>

@interface CoreDataManager ()

@property(nonatomic,strong)NSString *modelName;
@property(nonatomic,strong)NSPersistentContainer *container;

@end

@implementation CoreDataManager
- (instancetype)init:(NSString *)name {
    self = [super init];
    if(self) {
        self.modelName = name;
        [self createPersistentContainer];
    }
    return self;
}

- (void)createPersistentContainer {
    self.container = [[NSPersistentContainer alloc] initWithName:self.modelName];
    [self.container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription * _Nonnull description, NSError * _Nullable error) {
        if(error) {
            CDMLog(@"[%@] Fail: error: %@", self.modelName, error);
            return;
        }
        CDMLog(@"[%@] Success: Load stores", self.modelName);
        [self parseEntities];
    }];
}

- (BOOL)createEntity:(NSString *)name block:(void(^)(NSManagedObject * _Nonnull entity))block {
    @synchronized(self) {
        if(!self.container) {
            CDMLog(@"[%@] Fail: The container is nil", name);
            return NO;
        }
        
        NSManagedObjectContext *context = self.container.viewContext;
        NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:context];
        block(entity);
        
        if(context.hasChanges) {
            if([context save:nil]) {
                CDMLog(@"[%@] Success", name);
                return YES;
            }
            else {
                CDMLog(@"[%@] Fail", name);
            }
        }
        return NO;
    }
}

- (NSArray *)getEntity:(NSString *)name format:(NSString * _Nullable)format {
    @synchronized(self) {
        if(!self.container) {
            CDMLog(@"[%@] Fail: The container is nil", name);
            return nil;
        }
        
        NSManagedObjectContext *context = self.container.viewContext;
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:name];
        if(format) {
            fetch.predicate = [NSPredicate predicateWithFormat:format];
        }
        
        NSArray *entities = [context executeFetchRequest:fetch error:nil];
        if(entities) {
            CDMLog(@"[%@] Success (format = %@)", name, format);
            return entities;
        }
        CDMLog(@"[%@] Fail", name);
        return nil;
    }
}

- (BOOL)updateEntity:(NSString *)name format:(NSString * _Nullable)format block:(void(^)(NSManagedObject * _Nonnull entity))block {
    @synchronized(self) {
        if(!self.container) {
            CDMLog(@"[%@] Fail: The container is nil", name);
            return NO;
        }
        
        NSManagedObjectContext *context = self.container.viewContext;
        NSFetchRequest *fetchGroup = [[NSFetchRequest alloc] initWithEntityName:name];
        if(format) {
            fetchGroup.predicate = [NSPredicate predicateWithFormat:format];
        }
        
        NSArray *entities = [context executeFetchRequest:fetchGroup error:nil];
        if(entities) {
            for(id entity in entities) {
                block(entity);
            }
            
            if(context.hasChanges && [context save:nil]) {
                CDMLog(@"[%@] Success (format = %@)", name, format);
                return YES;
            }
        }
        CDMLog(@"[%@] Fail", name);
        return NO;
    }
}

- (BOOL)deleteEntity:(NSString *)name format:(NSString * _Nullable)format {
    @synchronized(self) {
        if(!self.container) {
            CDMLog(@"[%@] Fail: The container is nil", name);
            return NO;
        }
        
        NSManagedObjectContext *context = self.container.viewContext;
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:name];
        if(format) {
            fetch.predicate = [NSPredicate predicateWithFormat:format];
        }
        
        NSArray *entities = [context executeFetchRequest:fetch error:nil];
        if(entities) {
            for(id entity in entities) {
                [context deleteObject:entity];
            }
            
            if(context.hasChanges && [context save:nil]) {
                CDMLog(@"[success] delete %@ [format=%@]", name, format);
                return YES;
            }
        }
        CDMLog(@"[%@] Fail", name);
        return NO;
    }
}

- (void)parseEntities {
    NSArray *entities = self.container.managedObjectModel.entities;
    CDMLog(@"[%@] Entity count = %lu", self.modelName, entities.count);
    for(NSEntityDescription *entity in entities) {
        CDMLog(@"[%@] Entity name = %@", self.modelName, entity.name);
        for(NSPropertyDescription *property in entity.properties) {
            CDMLog(@"[%@] Property name = %@", self.modelName, property.name);
        }
    }
}

@end

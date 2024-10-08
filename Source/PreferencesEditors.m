//
//  PreferencesEditors.m
//  iLocalize3
//
//  Created by Jean on 06.07.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "PreferencesEditors.h"
#import "FMManager.h"
#import "FMModule.h"

@implementation PreferencesEditors

static PreferencesEditors *prefs = nil;

+ (id)shared
{
    @synchronized(self)
    {
        if (prefs == nil)
            prefs = [[PreferencesEditors alloc] init];
    }
    
    return prefs;
}

+ (NSMutableDictionary *)editor:(NSString *)editor extension:(NSString *)extension
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"editor"] = editor;
    dic[@"extension"] = extension;
    
    return dic;
}

+ (NSMutableArray *)defaultEditors
{
    NSMutableArray *editors = [NSMutableArray array];
    
    // nib type has been removed in 3.8 because it is automatically handled by ib3path or ib2path below
    [editors addObject:[PreferencesEditors editor:@"TextEdit" extension:@"strings"]];
    [editors addObject:[PreferencesEditors editor:@"TextEdit" extension:@"txt"]];
    [editors addObject:[PreferencesEditors editor:@"TextEdit" extension:@"rtf"]];
    [editors addObject:[PreferencesEditors editor:@"TextEdit" extension:@"rtfd"]];
    [editors addObject:[PreferencesEditors editor:@"Property List Editor" extension:@"plist"]];
    [editors addObject:[PreferencesEditors editor:@"Preview" extension:@"tiff"]];
    [editors addObject:[PreferencesEditors editor:@"Preview" extension:@"jpeg"]];
    [editors addObject:[PreferencesEditors editor:@"Preview" extension:@"tif"]];
    [editors addObject:[PreferencesEditors editor:@"Preview" extension:@"jpg"]];
    [editors addObject:[PreferencesEditors editor:@"Preview" extension:@"gif"]];
    [editors addObject:[PreferencesEditors editor:@"Preview" extension:@"png"]];
    
    return editors;
}

+ (void)initialize
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];

    dic[@"ExternalEditors"] = [PreferencesEditors defaultEditors];    
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:dic];
}

- (id)init
{
    if (self = [super init])
    {
        prefs = self;
        mEditingEditor = nil;
        
        NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
        
        // load my resources
        if (![myBundle loadNibNamed:@"PreferencesEditors" owner:self topLevelObjects:nil])
        {
            // throw exception
            @throw [NSException exceptionWithName:@"View initialization failed"
                                           reason:@"PreferencesEditors: Could not load resources!"
                                         userInfo:nil];
        }
    }
    
    return self;
}

- (void)awakeFromNib
{
    [mEditorsTableView setTarget:self];
    [mEditorsTableView setDoubleAction:@selector(editExternalEditor:)];

    NSEnumerator *enumerator = [[[FMManager shared] fileModules] objectEnumerator];
    FMModule *module;
    while(module = [enumerator nextObject]) {   
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        info[@"type"] = [module name];
        info[@"module"] = [NSValue valueWithNonretainedObject:module];
        
        NSMutableArray *extensions = [NSMutableArray array];
        NSEnumerator *extEnumerator = [[[FMManager shared] fileExtensionsForFileModule:module] objectEnumerator];
        NSString *ext;
        while(ext = [extEnumerator nextObject]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"extension"] = ext;
            dic[@"builtin"] = @YES;
            [extensions addObject:dic];
        }
        info[@"extensions"] = extensions;
        [mBuiltinTypesController addObject:info];
    }
    [mBuiltinTypesController setSelectionIndex:0];
    [mBuiltinTypesController rearrangeObjects];
}

- (void)loadData:(NSDictionary*)data
{
    NSEnumerator *enumerator = [data keyEnumerator];
    NSString *name;
    while(name = [enumerator nextObject]) {        
        NSEnumerator *typeEnumerator = [[mBuiltinTypesController content] objectEnumerator];
        NSDictionary *typeDic;
        while(typeDic = [typeEnumerator nextObject]) {
            if([typeDic[@"type"] isEqualToString:name]) {
                NSEnumerator *custExtEnumerator = [data[name] objectEnumerator];
                NSString *ext;
                while(ext = [custExtEnumerator nextObject]) {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    dic[@"extension"] = ext;
                    dic[@"builtin"] = @NO;
                    [typeDic[@"extensions"] addObject:dic];                    
                }
            }
        }            
    }
}

- (NSDictionary*)data
{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    // Store only the custom defined types
    
    NSEnumerator *enumerator = [[mBuiltinTypesController content] objectEnumerator];
    NSDictionary *typeDic;
    while(typeDic = [enumerator nextObject]) {
        NSMutableArray *customExtensions = [NSMutableArray array];
        
        NSEnumerator *extEnumerator = [typeDic[@"extensions"] objectEnumerator];
        NSDictionary *extDic;
        while(extDic = [extEnumerator nextObject]) {
            if(![extDic[@"builtin"] boolValue])
                [customExtensions addObject:extDic[@"extension"]];
        }
        
        data[typeDic[@"type"]] = customExtensions;
    }
    
    return data;
}

- (NSString*)editorForExtension:(NSString*)extension
{
    NSArray *editors = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ExternalEditors"];
    NSEnumerator *enumerator = [editors objectEnumerator];
    NSDictionary *dic;
    while(dic = [enumerator nextObject]) {
        if([dic[@"extension"] isEqualCaseInsensitiveToString:extension])
            return dic[@"editor"];
    }
    return nil;
}

- (FMModule*)moduleForExtension:(NSString*)extension
{
    NSEnumerator *enumerator = [[mBuiltinTypesController content] objectEnumerator];
    NSDictionary *typeDic;
    while(typeDic = [enumerator nextObject]) {
        NSEnumerator *extEnumerator = [typeDic[@"extensions"] objectEnumerator];
        NSDictionary *extDic;
        while(extDic = [extEnumerator nextObject]) {
            if(![extDic[@"builtin"] boolValue]) {
                if([extDic[@"extension"] isEqualCaseInsensitiveToString:extension])
                    return [typeDic[@"module"] nonretainedObjectValue];
            }
        }
    }
    return nil;
}

- (FMModule*)selectedModule
{
    return [[mBuiltinTypesController selectedObjects] firstObject][@"module"];
}

- (void)editNewInternalEditor
{
    int row = [[mBuiltinExtensionsController content] count]-1;
    [mBuiltinExtensionsTableView editColumn:0 row:row withEvent:nil select:NO];        
}

- (IBAction)addInternalEditor:(id)sender
{
    [mBuiltinExtensionsController addObject:[mBuiltinExtensionsController newObject]];
    
    int row = [[mBuiltinExtensionsController content] count]-1;
    [mBuiltinExtensionsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    [self performSelector:@selector(editNewInternalEditor) withObject:nil afterDelay:0];
}

#pragma mark -

- (IBAction)editExternalEditor:(id)sender
{
    mEditingEditor = [[mEditorsController selectedObjects] firstObject];
    
    [mExternalExtensionField setStringValue:mEditingEditor[@"extension"]];
    [mExternalAppField setStringValue:mEditingEditor[@"editor"]];
    
    [NSApp beginSheet:mExternalPanel modalForWindow:mWindow modalDelegate:self didEndSelector:nil contextInfo:nil];    
}

- (IBAction)addExternalEditor:(id)sender
{
    mEditingEditor = nil;

    [mExternalExtensionField setStringValue:@""];
    [mExternalAppField setStringValue:@""];

    [NSApp beginSheet:mExternalPanel modalForWindow:mWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
}

#pragma mark -

- (IBAction)externalPanelChoose:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setDirectoryURL:[NSURL fileURLWithPath:@"/Applications"]];
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            [mExternalAppField setStringValue:[[[[panel URL] path] lastPathComponent] stringByDeletingPathExtension]];        
        }
    }];
}

- (IBAction)externalPanelCancel:(id)sender
{
    [NSApp endSheet:mExternalPanel];
    [mExternalPanel orderOut:self];    
}

- (IBAction)externalPanelOK:(id)sender
{
    if(mEditingEditor) {
        mEditingEditor[@"extension"] = [mExternalExtensionField stringValue];
        mEditingEditor[@"editor"] = [mExternalAppField stringValue];
        [[[NSUserDefaultsController sharedUserDefaultsController] values] setValue:[mEditorsController content] forKey:@"ExternalEditors"];
    } else {
        [mEditorsController addObject:[PreferencesEditors editor:[mExternalAppField stringValue]
                                                          extension:[mExternalExtensionField stringValue]]];
        
        int row = [[mEditorsController content] count]-1;
        [mEditorsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
        [mEditorsTableView scrollRowToVisible:row];        
    }
    
    [NSApp endSheet:mExternalPanel];
    [mExternalPanel orderOut:self];
}

@end

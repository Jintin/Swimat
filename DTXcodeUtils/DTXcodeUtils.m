#import "DTXcodeUtils.h"

#import "DTXcodeHeaders.h"

@implementation DTXcodeUtils

+ (NSWindow *)currentWindow {
  return [[NSApplication sharedApplication] keyWindow];
}

+ (NSResponder *)currentWindowResponder {
  return [[self currentWindow] firstResponder];
}

+ (NSMenu *)mainMenu {
  return [NSApp mainMenu];
}

+ (NSMenuItem *)getMainMenuItemWithTitle:(NSString *)title {
  return [[self mainMenu] itemWithTitle:title];
}

+ (IDEWorkspaceWindowController *)currentWorkspaceWindowController {
  NSLog(@"getting window controller");
  NSWindowController *result = [self currentWindow].windowController;
  if ([result isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
    return (IDEWorkspaceWindowController *)result;
  }
  return nil;
}

+ (IDEEditorArea *)currentEditorArea {
  return [self currentWorkspaceWindowController].editorArea;
}

+ (IDEEditorContext *)currentEditorContext {
  return [self currentEditorArea].lastActiveEditorContext;
}

+ (IDEEditor *)currentEditor {
  return [self currentEditorContext].editor;
}

+ (IDESourceCodeDocument *)currentSourceCodeDocument {
  if ([[self currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
    return ((IDESourceCodeEditor *)[self currentEditor]).sourceCodeDocument;
  } else if ([[self currentEditor] isKindOfClass:
      NSClassFromString(@"IDESourceCodeComparisonEditor")]) {
    IDEEditorDocument *document =
        ((IDESourceCodeComparisonEditor *)[self currentEditor]).primaryDocument;
    if ([document isKindOfClass:NSClassFromString(@"IDESourceCodeDocument")]) {
      return (IDESourceCodeDocument *)document;
    }
  }
  return nil;
}

+ (DVTSourceTextView *)currentSourceTextView {
  if ([[self currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
    return ((IDESourceCodeEditor *)[self currentEditor]).textView;
  } else if ([[self currentEditor] isKindOfClass:
      NSClassFromString(@"IDESourceCodeComparisonEditor")]) {
    return ((IDESourceCodeComparisonEditor *)[self currentEditor]).keyTextView;
  }
  return nil;
}

+ (DVTTextStorage *)currentTextStorage {
  NSTextView *textView = [self currentSourceTextView];
  if ([textView.textStorage isKindOfClass:NSClassFromString(@"DVTTextStorage")]) {
    return (DVTTextStorage *)textView.textStorage;
  }
  return nil;
}

+ (NSScrollView *)currentScrollView {
  NSView *view = [self currentSourceTextView];
  return [view enclosingScrollView];
}

@end

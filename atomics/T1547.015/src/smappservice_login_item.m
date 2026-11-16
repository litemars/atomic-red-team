#import <Foundation/Foundation.h>
#import <ServiceManagement/ServiceManagement.h>

static const char *status_name(SMAppServiceStatus status) {
  switch (status) {
  case SMAppServiceStatusNotRegistered:
    return "NotRegistered";
  case SMAppServiceStatusEnabled:
    return "Enabled";
  case SMAppServiceStatusRequiresApproval:
    return "RequiresApproval";
  case SMAppServiceStatusNotFound:
    return "NotFound";
  }
  return "Unknown";
}

static void print_error(NSString *operation, NSError *error) {
  fprintf(stderr, "%s failed: %s\n", operation.UTF8String,
          error.localizedDescription.UTF8String);
}

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    if (argc == 1) {
      BOOL created = [[NSFileManager defaultManager]
          createFileAtPath:@"/tmp/T1547.015-smappservice-ran"
                  contents:nil
                attributes:nil];
      return created ? 0 : 1;
    }

    SMAppService *service = [SMAppService mainAppService];
    NSString *action = [NSString stringWithUTF8String:argv[1]];

    if ([action isEqualToString:@"register"]) {
      NSError *error = nil;
      if (![service registerAndReturnError:&error]) {
        print_error(action, error);
        return 1;
      }
    } else if ([action isEqualToString:@"unregister"]) {
      NSError *error = nil;
      if (![service unregisterAndReturnError:&error]) {
        print_error(action, error);
        return 1;
      }
    } else if (![action isEqualToString:@"status"]) {
      fprintf(stderr, "Usage: %s {register|status|unregister}\n", argv[0]);
      return 64;
    }

    printf("SMAppService status: %s\n", status_name(service.status));
    return service.status == SMAppServiceStatusNotFound ? 1 : 0;
  }
}

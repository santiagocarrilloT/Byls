import { NativeWindStyleSheet } from "nativewind";
import { registerRootComponent } from "expo";

NativeWindStyleSheet.setOutput({
  default: "native",
});

export { registerRootComponent };

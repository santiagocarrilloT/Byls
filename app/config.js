import "@expo/metro-runtime";
//importar la herramienta para que funcione nativewind
import { NativeWindStyleSheet } from "nativewind";

NativeWindStyleSheet.setOutput({
  default: "native",
});

export { registerRootComponents };

import { StatusBar } from "expo-status-bar";
import { StyleSheet, Text, View } from "react-native";
import "@expo/metro-runtime";
import "nativewind";
//importar la herramienta para que funcione nativewind
import { NativeWindStyleSheet } from "nativewind";

NativeWindStyleSheet.setOutput({
  default: "native",
});

import {}

export default function App() {
  return (
    <View className="flex-1 items-center justify-center bg-blue-300">
      <Text className="text-slate-800">Styling just works! 🎉</Text>
    </View>
  );
}

import { View, Text, TextInput, Pressable } from "react-native-web";

import "@expo/metro-runtime";
//importar la herramienta para que funcione nativewind
import { NativeWindStyleSheet } from "nativewind";

NativeWindStyleSheet.setOutput({
  default: "native",
});

export default function Layout() {
  return (
    <View className="flex-1 justify-center items-center bg-white p-6 sm:p-8 md:p-10">
      <Text className="text-3xl sm:text-4xl md:text-5xl font-bold text-center mb-8">
        Iniciar Sesión
      </Text>

      <TextInput
        className="w-full sm:w-3/4 md:w-1/2 bg-gray-100 p-4 mb-4 rounded-lg"
        placeholder="Correo electrónico"
      />
      <TextInput
        className="w-full sm:w-3/4 md:w-1/2 bg-gray-100 p-4 mb-6 rounded-lg"
        placeholder="Contraseña"
        secureTextEntry
      />

      <Pressable
        className="bg-blue-500 w-full sm:w-3/4 md:w-1/2 p-4 rounded-lg"
        disabled={""}
      >
        <Text className="text-center text-white text-lg">Iniciar Sesión</Text>
      </Pressable>
    </View>
  );
}

import {
  View,
  Text,
  TextInput,
  Pressable,
  Image,
  StyleSheet,
} from "react-native";

import { useEffect, useState } from "react";
import "expo";
import "../../supabase";
import { onSignIn } from "../../Backend/autenticacion/login";

export default function Layout() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [cuentas, setCuentas] = useState([]);

  /*useEffect(() => {
    const fetchPosts = async () => {
      const { data, error } = await supabase
        .from("Cuentas")
        .select("*")
        .eq("id_Usuario", "1167d4ca-ef86-4fda-a408-330e9d83f51f");

      if (error) {
        console.log(error);
      } else {
        setCuentas(data);
      }
    };
    fetchPosts();
  }, []);*/

  //console.log("Hola", cuentas);

  return (
    <View className="flex-1 justify-center items-center bg-cyan-50 p-6 sm:p-8 md:p-10">
      <Image
        source={require("../../assets/IconByls2.png")}
        style={styles.logo}
      ></Image>

      <Text className="text-3xl sm:text-4xl md:text-5xl font-bold text-center mb-8">
        Inicio de Sesión
      </Text>

      <TextInput
        className="w-full text-gray-500 sm:w-3/4 md:w-1/2 bg-gray-300 p-4 mb-4 rounded-lg"
        placeholder="Correo electrónico"
        onChangeText={(text) => setEmail(text)}
      />
      <TextInput
        className="w-full text-gray-500 sm:w-3/4 md:w-1/2 bg-gray-300 p-4 mb-6 rounded-lg"
        placeholder="Contraseña"
        secureTextEntry={true}
        onChangeText={(text) => setPassword(text)}
      />

      <Pressable
        className="bg-blue-500 w-full sm:w-3/4 md:w-1/2 p-4 rounded-lg"
        disabled={""}
        onPress={() => {
          onSignIn(email, password);
        }}
      >
        <Text className="text-center text-white text-lg">Iniciar Sesión</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  logo: {
    width: 220,
    height: 220,
    marginTop: -14,
    marginBottom: 0,
  },
});

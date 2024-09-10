import { config } from "dotenv";
config(); // Carga las variables del archivo .env

export default {
  expo: {
    name: "Bysl",
    slug: "bysl",
    version: "1.0.0",
    sdkVersion: "49.0.0",
    extra: {
      supabaseURL: process.env.SUPABASE_URL,
      supabaseAnonKey: process.env.SUPABASE_ANON_KEY,
    },
  },
};

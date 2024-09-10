import { createClient } from "@supabase/supabase-js";
import Constants from "expo-constants";

const supabaseURL = Constants.expoConfig.extra.supabaseURL;
const supabaseAnonKey = Constants.expoConfig.extra.supabaseAnonKey;

export const supabase = createClient(supabaseURL, supabaseAnonKey);

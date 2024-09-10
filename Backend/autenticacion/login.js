import { supabase } from "../../supabase";

export async function onSignUp(email, password) {
  try {
    const { user } = await supabase.auth.signUp({
      email: email,
      password: password,
    });
    if (error) {
      throw error;
    }
    console.log(user, "Signed up");
  } catch (error) {
    console.log(error);
  }
}

export async function onSignIn(email, password) {
  try {
    const { data, error } = await supabase.auth.signInWithPassword({
      email: email,
      password: password,
    });
    if (error) {
      throw error;
    }
    console.log(data.user, "Signed in");
    return data;
  } catch (error) {
    console.log(error);
    return "error";
  }
}

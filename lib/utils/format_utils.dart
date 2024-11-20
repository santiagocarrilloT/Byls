class FormatoUtils {
  String formatNumber(double valor) {
    if (valor == 0) {
      return valor.toStringAsFixed(2);
    }
    //Convertir a String
    String valorString = valor.toString();
    //Separar la parte entera de la decimal
    List<String> split = valorString.split('.');
    String parteEntera = split[0].split('').reversed.join();
    String parteDecimal = split.length > 1 ? split[1] : '00';
    String separarDecimales(
        String valor, String valorAcumulado, int ind, int contDecimales) {
      // Si el índice es mayor a la longitud de la parte entera, se retorna el valor acumulado
      if (parteEntera.length - 1 < ind) {
        return '$valorAcumulado.$parteDecimal';
      } else {
        // Si el índice es múltiplo de 3 se agrega una coma, si no se agrega el valor
        if (contDecimales % 3 == 0 && contDecimales != 0) {
          return separarDecimales(
              valor, '${parteEntera[ind]},$valorAcumulado', ind + 1, 0);
        } else {
          return separarDecimales(valor, parteEntera[ind] + valorAcumulado,
              ind + 1, contDecimales + 1);
        }
      }
    }

    return separarDecimales(parteEntera, '', 0, 0);
  }
}
